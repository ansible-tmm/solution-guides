{% raw %}
<div class="guide-header">

<h1>Guest OS and application configuration</h1>

<span class="guide-type-badge guide-type-badge--use-case"><i class="fas fa-layer-group" aria-hidden="true"></i> Virtualization Use Case</span>

</div>

<style>
  div#toc {
    display: none;
  }
</style>

## Overview

After the VM exists on OpenShift Virtualization, use Ansible to optimize the guest (tools, OS settings) and install applications with native Linux or Windows modules. Network, DNS, load balancers, firewalls, and ITSM updates can ride the same workflow so day-1 state matches intent.

**Maturity:** Walk (Initial Deployment). **Customer question:** How do we configure guests and deploy apps without day-1 drift?

Start from the [Common virtualization automation use cases hub](virtualization-use-cases.md) or the foundational [Virtualization automation with Ansible](README-Virtualization.md) guide.

## Background

AVA 301 separates OpenShift Virtualization automation (provision) from guest and infra automation (optimize / install application / orchestration). This use case covers guest and application day-1 configuration using dynamic inventory from kubevirt, system roles for hardening, and standard Ansible modules for application deployment.

### Key modules and plugins

| Module / Plugin | Collection | Purpose |
|----------------|-----------|---------|
| kubevirt inventory plugin | `kubernetes.core` | Dynamic inventory of VMs by namespace and label |
| `rhel_system_roles.firewall` | `redhat.rhel_system_roles` | Guest firewall configuration |
| `rhel_system_roles.timesync` | `redhat.rhel_system_roles` | NTP / chrony configuration |
| `rhel_system_roles.crypto_policies` | `redhat.rhel_system_roles` | System-wide crypto policy |
| `dnf`, `service`, `template` | `ansible.builtin` | Package management, services, config files |

## Solution

- **Ansible Automation Platform** with guest credentials (SSH/WinRM)
- **Dynamic inventory** from OpenShift Virtualization / kubevirt
- **RHEL system roles** for hardening baselines
- **Linux and Windows modules** plus optional ITSM / DNS / firewall jobs

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|----------------|
| **App owners** | Golden image drift after create | Repeatable guest and app playbooks |
| **Virt admins** | Manual guest tooling | Automated optimize step after provision |
| **Ops** | Infra and CMDB out of sync | Orchestrated ITSM and network follow-ons |

## Prerequisites

- AAP 2.5+ with guest SSH credentials (machine credential) or WinRM for Windows guests
- Execution environment with `redhat.rhel_system_roles`, `kubernetes.core`, and guest connectivity
- Guests must have `qemu-guest-agent` running (set up via cloud-init in [use case 4](README-Virtualization-Use-Case-04-VM-Provisioning.md))
- Network path from execution environment to guest VMs (pod network or `NodePort` / `LoadBalancer` service)

## Workflow

```mermaid
graph LR
  VM([VM Running]) --> Inventory[kubevirt inventory]
  Inventory --> Guest[Guest hardening]
  Guest --> App[Application deploy]
  App --> Verify[Service verification]
  Verify --> Infra([DNS / ITSM update])
```

## Solution Walkthrough

### Step 1: Configure kubevirt dynamic inventory

Create an inventory source in Controller that uses the kubevirt inventory plugin. This inventory file targets VMs by namespace and label so you only configure the VMs from a specific provisioning wave or application group.

```yaml
# kubevirt-inventory.yml -- add as an inventory source in AAP Controller
plugin: kubernetes.core.k8s
connections:
  - kubeconfig: "{{ lookup('env', 'K8S_AUTH_KUBECONFIG') }}"

compose:
  ansible_host: >-
    status.interfaces[0].ipAddress
  ansible_user: ansible

groups:
  rhel_guests: >-
    status.guestOSInfo.name is defined
    and 'Red Hat' in status.guestOSInfo.name
  windows_guests: >-
    status.guestOSInfo.name is defined
    and 'Windows' in status.guestOSInfo.name

resources:
  - group: virtualmachineinstances
    api_version: kubevirt.io/v1
    namespaces:
      - vms
      - production
```

Verify inventory discovery from the execution environment:

```bash
ansible-inventory -i kubevirt-inventory.yml --graph
ansible-inventory -i kubevirt-inventory.yml --host <vm-name>
```

### Step 2: Harden guest OS with RHEL system roles

Apply security baselines, time synchronization, and firewall rules as code. These same playbooks serve as drift detection when re-run on day 2.

**Operational Impact:** Low to Medium -- changes OS-level security settings.

```yaml
---
- name: Harden RHEL guest OS
  hosts: rhel_guests
  become: true
  vars:
    timesync_ntp_servers:
      - hostname: time.corp.example.com
        iburst: true
      - hostname: 0.rhel.pool.ntp.org
        iburst: true
    crypto_policies_policy: FUTURE
    firewall:
      - service: ssh
        state: enabled
        permanent: true
      - service: http
        state: enabled
        permanent: true
      - service: https
        state: enabled
        permanent: true
      - port: "9090/tcp"
        state: enabled
        permanent: true
  roles:
    - role: redhat.rhel_system_roles.timesync
    - role: redhat.rhel_system_roles.crypto_policies
    - role: redhat.rhel_system_roles.firewall

  tasks:
    - name: Ensure qemu-guest-agent is running
      ansible.builtin.service:
        name: qemu-guest-agent
        state: started
        enabled: true

    - name: Set hostname to match VM name
      ansible.builtin.hostname:
        name: "{{ inventory_hostname }}"

    - name: Configure SELinux to enforcing
      ansible.posix.selinux:
        state: enforcing
        policy: targeted

    - name: Install baseline security packages
      ansible.builtin.dnf:
        name:
          - aide
          - audit
          - rsyslog
          - firewalld
        state: present
```

### Step 3: Deploy application and configure services

Install and configure application workloads. This example deploys a web server with a custom configuration template.

```yaml
---
- name: Deploy web application on guest
  hosts: rhel_guests
  become: true
  vars:
    app_name: "{{ hostvars[inventory_hostname]['labels']['app'] | default('webapp') }}"
    app_port: 8080
    app_doc_root: /var/www/html
  tasks:
    - name: Install application packages
      ansible.builtin.dnf:
        name:
          - httpd
          - mod_ssl
          - python3
        state: present

    - name: Deploy httpd configuration
      ansible.builtin.template:
        src: templates/httpd.conf.j2
        dest: /etc/httpd/conf.d/{{ app_name }}.conf
        owner: root
        group: root
        mode: "0644"
      notify: Restart httpd

    - name: Deploy application content
      ansible.builtin.copy:
        src: "files/{{ app_name }}/"
        dest: "{{ app_doc_root }}/"
        owner: apache
        group: apache
        mode: "0644"

    - name: Enable and start httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true

    - name: Verify application responds
      ansible.builtin.uri:
        url: "http://localhost:{{ app_port }}/health"
        return_content: true
        status_code: 200
      register: health_check
      retries: 5
      delay: 5

  handlers:
    - name: Restart httpd
      ansible.builtin.service:
        name: httpd
        state: restarted
```

### Step 4: Register with DNS and load balancer

After application deployment, update DNS records and register the new VM with the load balancer. Optionally update ITSM with the new asset.

```yaml
---
- name: Register VM with infrastructure services
  hosts: localhost
  connection: local
  gather_facts: false
  vars:
    vm_name: "{{ target_vm }}"
    vm_ip: "{{ hostvars[target_vm]['ansible_host'] }}"
    dns_zone: apps.example.com
  tasks:
    - name: Create DNS A record
      ansible.builtin.nsupdate:
        server: "{{ dns_server }}"
        zone: "{{ dns_zone }}"
        record: "{{ vm_name }}"
        type: A
        value: "{{ vm_ip }}"
        state: present
      when: dns_server is defined

    - name: Create OpenShift Service for the VM
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: "{{ vm_name }}-svc"
            namespace: "{{ vm_namespace | default('vms') }}"
          spec:
            selector:
              app: "{{ vm_name }}"
            ports:
              - name: http
                port: 80
                targetPort: 8080
              - name: https
                port: 443
                targetPort: 8443

    - name: Create Route for external access
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: route.openshift.io/v1
          kind: Route
          metadata:
            name: "{{ vm_name }}-route"
            namespace: "{{ vm_namespace | default('vms') }}"
          spec:
            host: "{{ vm_name }}.{{ dns_zone }}"
            to:
              kind: Service
              name: "{{ vm_name }}-svc"
            port:
              targetPort: http
```

## Validation

### Test

```bash
# Verify dynamic inventory resolves VMs
ansible-inventory -i kubevirt-inventory.yml --graph

# Ping all discovered guests
ansible -i kubevirt-inventory.yml rhel_guests -m ping

# Check hardening was applied
ansible -i kubevirt-inventory.yml rhel_guests -m command -a "chronyc sources" --become
ansible -i kubevirt-inventory.yml rhel_guests -m command -a "update-crypto-policies --show" --become

# Verify application service
ansible -i kubevirt-inventory.yml rhel_guests -m uri -a "url=http://localhost:8080/health"

# Confirm firewall rules
ansible -i kubevirt-inventory.yml rhel_guests -m command -a "firewall-cmd --list-all" --become
```

### Expected Result

```
Dynamic inventory lists VMs by namespace with IP addresses.
Ping succeeds for all reachable guests.
Chrony shows configured NTP sources; crypto policy returns FUTURE.
Application health endpoint returns 200.
Firewall shows ssh, http, https enabled.
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Unreachable guest | Network policy blocking SSH from EE pod | Add `NetworkPolicy` allowing EE egress to VM pod network |
| Inventory empty | Wrong namespace or missing guest agent | Verify `qemu-guest-agent` running; check inventory `namespaces` list |
| System roles fail | Missing role or wrong EE | Verify `redhat.rhel_system_roles` is in the EE; check `ansible-galaxy collection list` |
| Partial app install | Missing repos or proxy | Configure subscription-manager or satellite on guests first |
| DNS update fails | nsupdate permission or zone mismatch | Verify TSIG key and zone name match DNS server config |

## Maturity Path

| Maturity | For this use case |
|----------|-------------------|
| **Crawl** | Manual guest playbooks run after create |
| **Walk** | Provision workflow chains guest hardening + app deploy as workflow nodes |
| **Run** | Same content used for day-2 drift detection and repair; scheduled compliance checks |

## Summary

**Guest OS and application configuration** is use case 5 -- day-1 intent enforced with the same Ansible skills used for migration. Dynamic inventory from kubevirt, RHEL system roles for hardening, and standard modules for app deployment provide a repeatable, auditable path from VM provisioning to production-ready workload.

## Next Steps

1. Return to [Virtualization automation with Ansible](README-Virtualization.md).
2. Browse [all nine use cases](virtualization-use-cases.md).
3. Continue with [Snapshot and backup management](README-Virtualization-Use-Case-06-Snapshot-and-Backup.md).
{% endraw %}
