{% raw %}
<div class="guide-header">

<h1>Discover and analyze</h1>

<span class="guide-type-badge guide-type-badge--use-case"><i class="fas fa-layer-group" aria-hidden="true"></i> Virtualization Use Case</span>

</div>

<style>
  div#toc {
    display: none;
  }
</style>

## Overview

Inventory your VMware environment and supporting hardware with Ansible before migration waves. Pull configuration facts from VMware vCenter and, where useful, Dell iDRAC or Redfish-compatible BIOS so reusable facts drive planning -- not spreadsheets.

**Maturity:** Crawl (Migration). **Customer question:** How do we inventory VMware and hardware before migration waves?

Start from the [Common virtualization automation use cases hub](virtualization-use-cases.md) or the foundational [Virtualization automation with Ansible](README-Virtualization.md) guide.

## Background

Discovery is the first step in any migration journey. Without a complete, repeatable inventory of the source VMware estate, teams rely on manual spreadsheets that go stale within days. AAP turns discovery into a governed, scheduled job that produces machine-readable facts -- VM counts, resource allocations, datastore usage, and hardware profiles -- feeding wave planning and MTV mapping decisions downstream.

The AVA 301 technical deck identifies two discovery scopes: **virtual infrastructure** (vCenter VMs, hosts, datastores, networks) and **physical hardware** (server models, firmware, BIOS settings via Redfish/iDRAC). Both are relevant when target OpenShift nodes must match specific hardware profiles or when hardware constraints affect migration ordering.

## Solution

- **Ansible Automation Platform** for governed discovery jobs and reusable facts
- **VMware and hardware collections** for vCenter and Redfish-style inventory
- **OpenShift Virtualization / MTV planning inputs** as downstream consumers of those facts

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|----------------|
| **Migration Team** | Unknown estate size and config drift | Facts-driven inventories for wave planning |
| **Platform Architect** | Manual discovery that goes stale | Scheduled AAP discovery with audit history |
| **Leadership** | Unclear migration scope | Measurable inventory before commit |

## Prerequisites

- Ansible Automation Platform with VMware credentials (vCenter read-only service account)
- Optional: Redfish/iDRAC credentials for hardware discovery
- Lab or pilot vSphere inventory for first runs
- Execution environment with `community.vmware`, `kubernetes.core`, and `community.general` (for Redfish)

## Workflow

```mermaid
graph LR
  Trigger([Schedule or manual]) --> VMware[Discover VMware estate]
  VMware --> Hardware[Discover hardware<br/>optional]
  Hardware --> Target[Check target cluster]
  Target --> Report[(Migration candidate<br/>report)]
  Report --> Plan([Wave planning])
```

## Solution Walkthrough

### Step 1: Discover the VMware estate

Gather VM, host, and datastore facts from vCenter. Store the output as a Controller job artifact for downstream consumption.

```yaml
---
- name: Discover VMware estate for migration planning
  hosts: localhost
  connection: local
  gather_facts: false
  vars:
    vcenter_hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
    vcenter_username: "{{ lookup('env', 'VMWARE_USER') }}"
    vcenter_password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
    vcenter_validate_certs: false
    report_dir: /tmp/migration-reports
  tasks:
    - name: Create report directory
      ansible.builtin.file:
        path: "{{ report_dir }}"
        state: directory
        mode: "0755"

    - name: Gather all VM information
      community.vmware.vmware_vm_info:
        hostname: "{{ vcenter_hostname }}"
        username: "{{ vcenter_username }}"
        password: "{{ vcenter_password }}"
        validate_certs: "{{ vcenter_validate_certs }}"
      register: vmware_vms

    - name: Gather host information
      community.vmware.vmware_host_info:
        hostname: "{{ vcenter_hostname }}"
        username: "{{ vcenter_username }}"
        password: "{{ vcenter_password }}"
        validate_certs: "{{ vcenter_validate_certs }}"
      register: vmware_hosts

    - name: Gather datastore information
      community.vmware.vmware_datastore_info:
        hostname: "{{ vcenter_hostname }}"
        username: "{{ vcenter_username }}"
        password: "{{ vcenter_password }}"
        validate_certs: "{{ vcenter_validate_certs }}"
      register: vmware_datastores

    - name: Build migration candidate list
      ansible.builtin.set_fact:
        migration_candidates: >-
          {{ vmware_vms.virtual_machines | map('combine',
             {'source_cluster': vcenter_hostname,
              'discovered_at': ansible_date_time.iso8601}) | list }}

    - name: Filter powered-on VMs as primary candidates
      ansible.builtin.set_fact:
        active_candidates: >-
          {{ migration_candidates
             | selectattr('power_state', 'equalto', 'poweredOn') | list }}

    - name: Write JSON migration report
      ansible.builtin.copy:
        content: "{{ report | to_nice_json }}"
        dest: "{{ report_dir }}/migration-candidates-{{ ansible_date_time.date }}.json"
        mode: "0644"
      vars:
        report:
          discovery_date: "{{ ansible_date_time.iso8601 }}"
          source: "{{ vcenter_hostname }}"
          total_vms: "{{ vmware_vms.virtual_machines | length }}"
          powered_on: "{{ active_candidates | length }}"
          total_hosts: "{{ vmware_hosts.hosts_info | length }}"
          total_datastores: "{{ vmware_datastores.datastores | length }}"
          candidates: "{{ active_candidates }}"

    - name: Write CSV summary for spreadsheet consumers
      ansible.builtin.template:
        src: templates/migration-candidates.csv.j2
        dest: "{{ report_dir }}/migration-candidates-{{ ansible_date_time.date }}.csv"
        mode: "0644"

    - name: Report summary
      ansible.builtin.debug:
        msg: >-
          Discovery complete. {{ active_candidates | length }} powered-on VMs
          across {{ vmware_hosts.hosts_info | length }} hosts and
          {{ vmware_datastores.datastores | length }} datastores.
          Report: {{ report_dir }}/migration-candidates-{{ ansible_date_time.date }}.json
```

CSV template (`templates/migration-candidates.csv.j2`):

```
vm_name,power_state,num_cpu,memory_mb,guest_os,ip_address,datacenter,cluster
{% for vm in active_candidates %}
{{ vm.guest_name }},{{ vm.power_state }},{{ vm.num_cpu }},{{ vm.memory_mb }},{{ vm.guest_id | default('unknown') }},{{ vm.ip_address | default('N/A') }},{{ vm.datacenter | default('') }},{{ vm.cluster | default('') }}
{% endfor %}
```

### Step 2: Discover hardware profiles (optional)

When target OpenShift nodes have hardware requirements or when firmware versions affect migration ordering, pull hardware facts via Redfish.

```yaml
---
- name: Discover hardware profiles via Redfish
  hosts: idrac_hosts
  gather_facts: false
  vars:
    redfish_user: "{{ lookup('env', 'REDFISH_USER') }}"
    redfish_password: "{{ lookup('env', 'REDFISH_PASSWORD') }}"
  tasks:
    - name: Gather system inventory via Redfish
      community.general.redfish_info:
        baseuri: "{{ inventory_hostname }}"
        username: "{{ redfish_user }}"
        password: "{{ redfish_password }}"
        category: Systems
        command: GetSystemInventory
      register: system_info

    - name: Gather firmware inventory
      community.general.redfish_info:
        baseuri: "{{ inventory_hostname }}"
        username: "{{ redfish_user }}"
        password: "{{ redfish_password }}"
        category: Update
        command: GetFirmwareInventory
      register: firmware_info

    - name: Build hardware profile
      ansible.builtin.set_fact:
        hardware_profile:
          host: "{{ inventory_hostname }}"
          model: "{{ system_info.redfish_facts.system.entries[0][1].Model | default('unknown') }}"
          manufacturer: "{{ system_info.redfish_facts.system.entries[0][1].Manufacturer | default('unknown') }}"
          serial: "{{ system_info.redfish_facts.system.entries[0][1].SerialNumber | default('unknown') }}"
          bios_version: "{{ system_info.redfish_facts.system.entries[0][1].BiosVersion | default('unknown') }}"
          total_memory_gb: "{{ system_info.redfish_facts.system.entries[0][1].MemorySummary.TotalSystemMemoryGiB | default(0) }}"
          processor_count: "{{ system_info.redfish_facts.system.entries[0][1].ProcessorSummary.Count | default(0) }}"

    - name: Display hardware summary
      ansible.builtin.debug:
        var: hardware_profile
```

### Step 3: Validate target cluster readiness

Confirm the target OpenShift cluster has OpenShift Virtualization and MTV installed and ready for migration plans.

```yaml
---
- name: Validate target OpenShift cluster readiness
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Check OpenShift Virtualization operator
      kubernetes.core.k8s_info:
        api_version: operators.coreos.com/v1alpha1
        kind: ClusterServiceVersion
        namespace: openshift-cnv
        label_selectors:
          - "operators.coreos.com/kubevirt-hyperconverged.openshift-cnv="
      register: cnv_csv

    - name: Assert OpenShift Virtualization is installed
      ansible.builtin.assert:
        that:
          - cnv_csv.resources | length > 0
          - cnv_csv.resources[0].status.phase == "Succeeded"
        fail_msg: "OpenShift Virtualization operator is not installed or not healthy"
        success_msg: "OpenShift Virtualization operator is healthy"

    - name: Check MTV operator
      kubernetes.core.k8s_info:
        api_version: operators.coreos.com/v1alpha1
        kind: ClusterServiceVersion
        namespace: openshift-mtv
        label_selectors:
          - "operators.coreos.com/mtv-operator.openshift-mtv="
      register: mtv_csv

    - name: Assert MTV operator is installed
      ansible.builtin.assert:
        that:
          - mtv_csv.resources | length > 0
          - mtv_csv.resources[0].status.phase == "Succeeded"
        fail_msg: "MTV operator is not installed or not healthy"
        success_msg: "MTV operator is healthy"

    - name: List existing VirtualMachines on target
      kubernetes.core.k8s_info:
        api_version: kubevirt.io/v1
        kind: VirtualMachine
      register: existing_vms

    - name: Check available storage classes
      kubernetes.core.k8s_info:
        api_version: storage.k8s.io/v1
        kind: StorageClass
      register: storage_classes

    - name: Report target readiness
      ansible.builtin.debug:
        msg: >-
          Target cluster ready. OpenShift Virtualization: {{ cnv_csv.resources[0].spec.version }}.
          MTV: {{ mtv_csv.resources[0].spec.version }}.
          Existing VMs: {{ existing_vms.resources | length }}.
          Storage classes: {{ storage_classes.resources | map(attribute='metadata.name') | list | join(', ') }}.
```

## Validation

### Test

```bash
# Verify VMware inventory plugin is configured and returning hosts
ansible-inventory -i inventories/vmware.yml --graph

# Confirm vCenter connectivity from the EE
ansible-playbook discover-vmware.yml --check -v

# Verify target cluster access
oc get csv -n openshift-cnv
oc get csv -n openshift-mtv
oc get vm -A
oc get sc
```

### Expected Result

```
VMware inventory returns expected hosts and VMs grouped by datacenter or cluster.
Discovery playbook completes with failed=0 and writes a JSON report.
Target cluster shows OpenShift Virtualization and MTV CSVs in Succeeded phase.
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Auth failures to vCenter | Credential or permission | Fix Controller credential; verify service account has at least read-only access |
| Empty VM list | Wrong datacenter or filter | Check `vmware_vm_info` filter parameters; remove restrictive `cluster_name` if set |
| Redfish connection refused | iDRAC not enabled or wrong port | Verify Redfish is enabled in iDRAC settings; default port is 443 |
| Target cluster not reachable | kubeconfig missing or expired | Add Controller credential type `OpenShift or Kubernetes API Bearer Token` |
| Storage classes empty | OpenShift Virtualization not fully deployed | Verify HyperConverged CR is in Available condition |

## Maturity Path

| Maturity | For this use case |
|----------|-------------------|
| **Crawl** | One-time or scheduled discovery feeding migration plans |
| **Walk** | Facts also drive provisioning and CMDB sync; hardware profiles feed capacity planning |
| **Run** | Continuous estate awareness into day-2 automation; delta reports flag drift |

## Summary

**Discover and analyze** is use case 1 in the Virtualization foundational set -- the Assess step of automate once, benefit always. AAP transforms VMware and hardware inventory from manual spreadsheets into governed, repeatable discovery jobs that produce machine-readable reports for wave planning.

## Next Steps

1. Return to [Virtualization automation with Ansible](README-Virtualization.md).
2. Browse [all nine use cases](virtualization-use-cases.md).
3. Continue with [Pre-migration validation](README-Virtualization-Use-Case-02-Pre-Migration-Validation.md).
{% endraw %}
