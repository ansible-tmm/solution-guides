{% raw %}
# Post-Quantum Cryptography Readiness for RHEL - Solution Guide <!-- omit in toc -->

> **Knowledge Base Article**: [https://access.redhat.com/articles/XXXXXXX](https://access.redhat.com/articles/XXXXXXX)
>
> While this Solution Guide can be found on the customer portal, this document is the source of truth.

<style>
  div#toc {
    display: none;
  }
</style>

<h2 id="overview"></h2>

## Overview

Most organizations cannot answer a basic question across their RHEL fleet: which certificates, SSH keys, TLS listeners, and crypto-policies still use quantum-vulnerable algorithms? Those primitives sit in OpenSSL, `/etc/pki`, sshd, and nginx. A single host has dozens of touchpoints. Manual inventory does not scale, and a one-off script does not produce the cryptographic bill of materials that auditors and migration plans now require.

NIST has published FIPS 203 (ML-KEM), 204 (ML-DSA), and 205 (SLH-DSA). OMB Memorandum M-26-15 (June 2026) directs federal civilian agencies to submit a PQC migration plan within 120 days and treats 2026-2027 as the discovery phase. Harvest-now-decrypt-later collection means data protected today is already in scope. This guide shows how Ansible Automation Platform turns that discovery mandate into a repeatable pipeline: scan with native OS tools, normalize findings, emit a CycloneDX CBOM, remediate by domain, then scan again to prove the new posture.

> **This is a Day 2 security and compliance pipeline.**
>
> Discovery is read-only. Remediation is tagged by domain (certificates, crypto-policy, nginx, sshd) and supports dry-run. You can stop after inventory if you are not ready to change production crypto.

- [Overview](#overview)
- [Background](#background)
- [Solution](#solution)
  - [Who Benefits](#who-benefits)
- [Prerequisites](#prerequisites)
  - [Ansible Automation Platform](#ansible-automation-platform)
  - [Featured Ansible Content Collections](#featured-ansible-content-collections)
  - [External Systems](#external-systems)
- [PQC Readiness Workflow](#pqc-readiness-workflow)
  - [Operational Impact per Stage](#operational-impact-per-stage)
  - [Workflow Architecture Diagram](#workflow-architecture-diagram)
- [Solution Walkthrough](#solution-walkthrough)
  - [1. Discover Cryptographic Posture](#1-discover-cryptographic-posture)
  - [2. Normalize Findings and Generate a CBOM](#2-normalize-findings-and-generate-a-cbom)
  - [3. Register Job Templates and Classify Inventory](#3-register-job-templates-and-classify-inventory)
  - [4. Deploy Vault as the Issuing CA](#4-deploy-vault-as-the-issuing-ca)
  - [5. Remediate by Domain](#5-remediate-by-domain)
  - [6. Re-scan and Prove the New Posture](#6-re-scan-and-prove-the-new-posture)
- [Validation](#validation)
  - [Troubleshooting](#troubleshooting)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)
- [Summary](#summary)

<h2 id="background"></h2>

## Background

**Post-quantum cryptography (PQC)** is the set of public-key algorithms designed to remain secure against a cryptographically relevant quantum computer. Shor's algorithm breaks RSA, ECDSA, ECDH, and finite-field Diffie-Hellman. Symmetric algorithms (AES, SHA-2) are not in the same class of failure, but every TLS handshake, SSH session, and certificate that relies on classical public-key crypto is.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://csrc.nist.gov/projects/post-quantum-cryptography">NIST Post-Quantum Cryptography project -- nist.gov</a>

The operational problem is not picking an algorithm. It is knowing what you already run. Cryptographic assets are not a CMDB field. They live in OpenSSL TLS 1.3 groups, system certificate stores, SSH host keys, sshd `KexAlgorithms`, nginx `ssl_certificate` paths, and the RHEL system-wide crypto-policy. NIST SP 1800-38B describes cryptographic discovery as the first migration work product. OMB M-26-15 makes that inventory a Phase 1 deliverable for federal civilian agencies, with a plan due to OMB and ONCD by late October 2026.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.whitehouse.gov/wp-content/uploads/2026/06/M-26-15-Execution-of-the-Migration-to-Post-Quantum-Cryptography.pdf">OMB M-26-15 -- whitehouse.gov</a>

A second constraint makes this different from SHA-1 or 1024-bit RSA migrations: the change set hits TLS, SSH, certificates, and system policy at once. Changing sshd key exchange can lock the automation platform out of the host. Replacing a certificate can break a TLS service. Discovery without a safe remediation path produces a spreadsheet. Remediation without discovery produces outages. Both need the same automation engine.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/security">Red Hat security topics -- redhat.com</a>

<h2 id="solution"></h2>

## Solution

What makes up the solution?

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f501.png" width="20" style="vertical-align:text-bottom;"> **Ansible Automation Platform (AAP)** to schedule discovery, gate remediation with RBAC and approvals, and hold classified inventory groups <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **`security.compliance_pqc_readiness`** collection for posture snapshots, CFF normalization, CBOM generation, and domain remediations <a target="_blank" href="https://github.com/cross-logic/PQC-AAP">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5a5.png" width="20" style="vertical-align:text-bottom;"> **Red Hat Enterprise Linux 8/9** as the scan and remediation target -- `openssl`, `ssh-keygen`, `ss`, and `update-crypto-policies` already on the box <a target="_blank" href="https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f511.png" width="20" style="vertical-align:text-bottom;"> **HashiCorp Vault** as an internal PKI CA that issues replacement certificates from an Intermediate CA <a target="_blank" href="https://www.vaultproject.io/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e6.png" width="20" style="vertical-align:text-bottom;"> **A custom Execution Environment** built from `ee-minimal-rhel9` so Controller jobs carry `community.crypto`, `community.hashi_vault`, and the PQC collection <a target="_blank" href="https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/creating_and_using_execution_environments/index">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4cb.png" width="20" style="vertical-align:text-bottom;"> **Optional Backstage compliance plugin** to ingest Common Findings Format (CFF) v1.0.0 JSON from the assessment job template <a target="_blank" href="https://github.com/cross-logic/aap-compliance-pipelines">[Link]</a>

> **Hybrid migration, not a big-bang cutover.**
>
> Hosts are classified `pqc_ready` when OpenSSL TLS 1.3 groups include ML-KEM. Vault in this collection issues ECDSA P-384 certificates. That matches current CA support: quantum-resistant key exchange first, classical signatures until ML-DSA issuance is available.

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e0.png" width="20" style="vertical-align:text-bottom;"> **IT Ops Engineer / SRE** | Cryptographic inventory is a spreadsheet of `openssl` one-liners. Changing sshd or system crypto-policy is high-risk and rarely rehearsed | Read-only snapshots with `changed=0`, dry-run remediations, backups with a `.pre-pqc` suffix, and `aap_impact` tags that warn before a change can break Ansible SSH |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5fa.png" width="20" style="vertical-align:text-bottom;"> **Security / Crypto Architect** | No single view of certificates, SSH keys, TLS KEX, and crypto-policy across the fleet. NIST discovery guidance has no executable implementation | A CycloneDX v1.6 CBOM per host with `nistQuantumSecurityLevel`, plus CFF findings that name rule IDs, severity, and a remediation role |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4bc.png" width="20" style="vertical-align:text-bottom;"> **Compliance Officer** | Phase 1 of M-26-15 and similar mandates ask for an automated cryptographic inventory. Evidence is assembled by hand | Scheduled AAP jobs, timestamped HTML/JSON reports, and machine-readable CBOMs aligned with NIST SP 1800-38B discovery |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4ca.png" width="20" style="vertical-align:text-bottom;"> **IT Director / CISO** | Quantum risk is treated as a 2035 problem while harvest-now-decrypt-later is already running. No crawl path that starts without changing production | A Crawl stage that is scan-only, a Walk stage with tagged remediations and approval, and a measurable `pqc_ready` / `pqc_not_ready` split in Controller inventory |

**Recommended Demos and Self-Paced Labs:**

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3d7.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://github.com/cross-logic/PQC-AAP">PQC-AAP collection and standalone playbooks</a> -- source for this guide, including `docs/standalone-usage.md`

<h2 id="prerequisites"></h2>

## Prerequisites

### Ansible Automation Platform

- **Ansible Automation Platform 2.5+** -- Controller API paths in `install.yml` use `/api/controller/v2/`. The sample Execution Environment is built from `registry.redhat.io/ansible-automation-platform-26/ee-minimal-rhel9:latest`.
- **ansible-core 2.15+** for standalone CLI runs outside Controller.
- Target hosts: **RHEL 8 or RHEL 9** with privilege escalation. ML-KEM TLS groups and the `FUTURE:PQC` crypto-policy sub-policy require a current RHEL 9 stream (OpenSSL 3.5+ is documented in the collection as RHEL 9.7+). RHEL 8 still produces a useful inventory; several remediations will fail closed until the OS can offer the algorithms.

> **Tip:** Build the EE before the first Controller job.
>
> Discovery uses tools on the *target*, but Controller still needs `community.crypto`, `community.hashi_vault`, `hvac`, and the PQC collection inside the EE.

### Featured Ansible Content Collections

| Collection | Type | Purpose |
|-----------|------|---------|
| <a target="_blank" href="https://github.com/cross-logic/PQC-AAP">security.compliance_pqc_readiness</a> | Custom | Snapshot role, `normalize_pqc`, `generate_cbom`, Vault PKI roles, and domain remediations. Not on Automation Hub; ship it inside the EE |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/posix/">ansible.posix</a> | Certified | POSIX helpers used with systemd and system configuration |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/">ansible.controller</a> | Certified | Create `PQC Crypto Assets` inventory and `pqc_ready` / `pqc_not_ready` groups |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/community/crypto/">community.crypto</a> | Community | `x509_certificate_info` for nginx and on-disk certificate inspection |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/community/hashi_vault/">community.hashi_vault</a> | Community | `vault_write` for PKI mounts, CA generation, and certificate issue |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/community/general/">community.general</a> | Community | General Linux helpers used by Vault deploy and PKI setup |

### External Systems

| System | Required | Examples |
|--------|----------|----------|
| RHEL 8/9 managed nodes | Yes | Inventory group `pqc_targets` |
| HashiCorp Vault | For certificate and nginx remediations | Vault 1.19.x as deployed by `playbooks/vault_deploy.yml`, or an existing PKI mount |
| Container registry | For AAP jobs | Quay or an internal registry to hold `compliance-pqc-readiness:latest` |
| Backstage compliance plugin | Optional | Direct POST to `/api/compliance/findings/ingest` from the collection pipeline playbook |
| Git project in AAP | Yes | Project pointing at this collection or a fork |

**Operational Impact:** None for discovery. High for system crypto-policy and sshd remediations. See the per-stage table below.

> **Warning:** Do not put Vault tokens in Git.
>
> Pass `vault_token` from an AAP credential lookup or extra vars at launch. After `vault_deploy`, move `init-keys.json` (unseal keys and root token) off the Vault server and delete the file.

<h2 id="pqc-readiness-workflow"></h2>

## PQC Readiness Workflow

A scheduled or manual job template launches discovery against `pqc_targets`. The `crypto_posture_snapshot` role runs `openssl`, `ssh-keygen`, `ss`, and `update-crypto-policies` with `changed_when: false` and builds a `pqc_crypto_report` fact. `normalize_pqc` turns that fact into CFF findings with rule IDs such as `pqc_openssl_mlkem_support` and `pqc_sshd_kex_algorithms`. `generate_cbom` writes a CycloneDX v1.6 document with `nistQuantumSecurityLevel` on each algorithm. Optional next hops are a POST into Backstage, or `sync_pqc_inventory.yml` which creates Controller groups `pqc_ready` and `pqc_not_ready`.

Remediation is a second workflow, not a side effect of the scan. `playbooks/remediate.yml` always re-scans first, then runs tagged plays for certificates, crypto-policy, nginx, and sshd. Certificate and nginx plays check Vault health before they issue. Every domain supports `*_dry_run=true`. After changes, the same snapshot role runs again and prints `pqc_ready` before versus `pqc_ready_after`.

### Operational Impact per Stage

| Stage | Impact | Description |
|-------|--------|-------------|
| 1. Cryptographic posture snapshot | None | Read-only commands on targets; reports written on the control node |
| 2. Normalize + CBOM | None | Fact transformation on Controller or localhost |
| 3. Inventory sync / JT install | Low | Creates AAP inventories, groups, and job templates only |
| 4. Vault deploy + PKI setup | Medium | Installs Vault, initializes Shamir shares, mounts PKI engines |
| 5. Certificate / nginx remediation | High | Replaces TLS material and reloads nginx; originals backed up |
| 6. Crypto-policy / sshd remediation | High | System-wide policy and sshd drop-in; default role restarts `sshd` and `nginx` after policy change |

### Workflow Architecture Diagram

```
  AAP Job Template / ansible-playbook
                 |
                 v
     +---------------------------+
     | crypto_posture_snapshot   |  openssl, ssh-keygen, ss,
     | (read-only, changed=0)    |  update-crypto-policies, x509
     +-------------+-------------+
                   |  pqc_crypto_report
                   v
     +---------------------------+
     | normalize_pqc  ->  CFF    |
     | generate_cbom  ->  CBOM   |
     +-------------+-------------+
                   |
         +---------+---------+
         v                   v
  Backstage ingest     AAP inventory
  (optional POST)      pqc_ready /
                       pqc_not_ready
                              |
                              v
                   +----------+-----------+
                   | remediate.yml (tags) |
                   | certs | policy |     |
                   | nginx | sshd         |
                   +----------+-----------+
                              |  Vault PKI for certs/nginx
                              v
                   Re-run snapshot
                   pqc_ready_after
```

<h2 id="solution-walkthrough"></h2>

## Solution Walkthrough

### 1. Discover Cryptographic Posture

**Operational Impact:** None

Point inventory at the `pqc_targets` group and run the snapshot playbook. The role does not install agents. Collectors are independently togglable (`pqc_collect_nginx_certs`, `pqc_collect_tls_services`, and so on) if you need a narrower first pass.

```yaml
- name: Query openssl version
  ansible.builtin.command:
    cmd: openssl version
  register: pqc_openssl_version_cmd
  changed_when: false
  failed_when: false
  when: pqc_collect_openssl | bool

- name: List TLS 1.3 groups (requires modern OpenSSL)
  ansible.builtin.command:
    cmd: openssl list -tls-groups -tls1_3
  register: pqc_openssl_tls_groups_cmd
  changed_when: false
  failed_when: false
  when: pqc_collect_openssl | bool
```

The role also records crypto-policy profile and FIPS state, SSH host key algorithms, system certificates, listening TLS ports, nginx certificate details, and sshd crypto directives. Those fields land in one fact:

```yaml
- name: Assemble cryptographic posture report
  ansible.builtin.set_fact:
    pqc_crypto_report:
      host: "{{ inventory_hostname }}"
      collected_at: "{{ ansible_date_time.iso8601 }}"
      openssl_version: "{{ pqc_openssl_version_cmd.stdout | default('') }}"
      openssl_tls1_3_groups: "{{ pqc_openssl_tls_groups_cmd.stdout | default('') }}"
      crypto_policy: "{{ pqc_crypto_policy | default({}) }}"
      ssh_host_keys: "{{ pqc_ssh_host_keys | default([]) }}"
      system_certificates: "{{ pqc_system_certificates | default([]) }}"
      tls_services: "{{ pqc_tls_services | default([]) }}"
      nginx_certificates: "{{ pqc_nginx_certificate_details | default([]) }}"
      sshd_crypto_lines: "{{ pqc_sshd_crypto_lines | default([]) }}"
```

**Job Template Configuration:**

| Field | Value |
|-------|-------|
| **Name** | `compliance-scan-pqc-readiness` |
| **Inventory** | RHEL targets (`pqc_targets`) |
| **Project** | `compliance-profile-pqc-readiness` |
| **Playbook** | `playbooks/crypto_posture_snapshot.yml` (standalone) or the collection `pqc_pipeline.yml` |
| **Execution Environment** | `compliance-pqc-readiness` |
| **Credentials** | Machine credential with `become` |
| **Extra vars** | `pqc_write_html_report: true`, `pqc_write_cbom: true` |

> **RBAC:** Scan is read-only. Grant Execute widely.
>
> Assign the `Execute` role on the assessment Job Template to the platform and security teams. Keep `Execute` on remediation templates to a smaller crypto-change group.

### 2. Normalize Findings and Generate a CBOM

**Operational Impact:** None

Raw posture is useful to an engineer. Auditors and compliance dashboards need a common schema. `normalize_pqc` emits CFF v1.0.0 findings. `generate_cbom` emits CycloneDX v1.6. The collection pipeline playbook does both after the snapshot, then optionally POSTs findings.

```yaml
- name: Normalize crypto posture per host
  security.compliance_pqc_readiness.normalize_pqc:
    crypto_report: "{{ hostvars[item].pqc_crypto_report }}"
    profile_id: "{{ compliance_profile }}"
    profile_name: "{{ profile_name }}"
    scan_id: "{{ scan_id }}"
  register: _pqc_results
  loop: "{{ groups['all'] | select('ne', 'localhost') | list }}"
  when: hostvars[item].pqc_crypto_report is defined

- name: Generate CBOM per host
  security.compliance_pqc_readiness.generate_cbom:
    crypto_report: "{{ hostvars[item].pqc_crypto_report }}"
  loop: "{{ groups['all'] | select('ne', 'localhost') | list }}"
  when:
    - hostvars[item].pqc_crypto_report is defined
    - pqc_write_cbom | default(false) | bool
```

Each finding carries `aap_impact` of `safe`, `caution`, or `breaks-connectivity`. SSH host-key removal and sshd KEX changes are `caution` because they can interrupt Controller connections. Use that field in surveys or approval nodes before you enable those tags.

Standalone CBOM from an existing fact:

```bash
ansible-playbook playbooks/generate_cbom.yml \
  -e pqc_cbom_output_file=/tmp/cbom-myhost.json
```

### 3. Register Job Templates and Classify Inventory

**Operational Impact:** Low

`install.yml` creates the assessment and remediation Job Templates plus per-domain templates (`pqc-vault-deploy`, `pqc-remediate-sshd`, and the rest). It reads `AAP_HOST` and `AAP_API_TOKEN` from the environment.

```bash
export AAP_HOST=https://controller.example.com
export AAP_API_TOKEN=<token>

ansible-playbook install.yml \
  -e organization=Default \
  -e project=compliance-profile-pqc-readiness \
  -e execution_environment=compliance-pqc-readiness \
  -e inventory=compliance-rhel-inventory
```

`sync_pqc_inventory.yml` classifies hosts from the snapshot. A host is `pqc_ready` when `openssl_tls1_3_groups` matches `mlkem` (case-insensitive). Controller then gets an inventory named `PQC Crypto Assets` with groups you can `--limit` on later remediations.

```yaml
- name: Classify host PQC readiness
  ansible.builtin.set_fact:
    pqc_ready: >-
      {{ (pqc_crypto_report.openssl_tls1_3_groups | default(''))
         is regex('(?i)mlkem') }}

- name: Create readiness groups
  ansible.controller.group:
    name: "{{ item }}"
    inventory: "{{ pqc_inventory_name }}"
    state: present
  loop:
    - pqc_not_ready
    - pqc_ready
```

> **RBAC:** Inventory write is a platform task.
>
> Grant the `Inventory Admin` or equivalent role on `PQC Crypto Assets` only to the automation architect team. Operators launching remediations need `Execute` plus permission to use that inventory.

### 4. Deploy Vault as the Issuing CA

**Operational Impact:** Medium

Skip this step if you already have a PKI mount that can issue the `pqc-server` / `pqc-nginx` roles. Otherwise deploy Vault onto the `vault_servers` group, then configure Root and Intermediate CAs (ECDSA P-384, 10-year and 5-year TTLs in the defaults).

```yaml
- name: Generate Root CA certificate
  community.hashi_vault.vault_write:
    url: "{{ vault_addr }}"
    token: "{{ vault_token }}"
    path: "{{ vault_pki_root_path }}/root/generate/internal"
    data:
      common_name: "{{ vault_pki_root_common_name }}"
      organization: "{{ vault_pki_root_organization }}"
      ttl: "{{ vault_pki_root_ttl }}"
      key_type: "{{ vault_pki_root_key_type }}"
      key_bits: "{{ vault_pki_root_key_bits }}"
      issuer_name: "{{ vault_pki_root_issuer_name }}"
  register: _root_ca_result
```

PKI setup also creates issuance roles, CRL/OCSP endpoints, and an AppRole named `pqc-cert-issuer` for Controller lookups. Store `role_id` and `secret_id` in a HashiCorp Vault credential type. Do not leave the root token in Job Template extra vars.

> **Warning:** Treat `init-keys.json` as a break-glass secret.
>
> `vault_deploy` writes Shamir unseal keys and the root token to disk at mode `0600`. Move that file to offline storage and delete it from the Vault host before the CA is used in production.

**Job Template Configuration:**

| Field | Value |
|-------|-------|
| **Name** | `pqc-vault-pki-setup` |
| **Inventory** | localhost / Controller |
| **Playbook** | `playbooks/vault_pki_setup.yml` |
| **Credentials** | Vault token or AppRole lookup |
| **Extra vars** | `vault_addr`, allowed domains in `vault_pki_roles` |

### 5. Remediate by Domain

**Operational Impact:** High

Run a dry-run against `pqc_not_ready` before any changing play. The orchestrator playbook is `playbooks/remediate.yml`. Tags: `remediate_certificates`, `remediate_crypto_policy`, `remediate_nginx`, `remediate_sshd`.

```bash
ansible-playbook playbooks/remediate.yml \
  --limit pqc_not_ready \
  -e vault_addr=https://vault.example.com:8200 \
  -e remediate_cert_dry_run=true \
  -e remediate_crypto_dry_run=true \
  -e remediate_nginx_dry_run=true \
  -e remediate_sshd_dry_run=true
```

**Certificates.** Non-PQC certs (RSA, ECDSA, DSA) are backed up, then replaced from the Intermediate CA. The issue task sets `no_log: true` so PEMs do not land in job output.

```yaml
- name: "Backup existing certificate: {{ _cert.path }}"
  ansible.builtin.copy:
    src: "{{ _cert.path }}"
    dest: "{{ _cert.path }}.pre-pqc.{{ ansible_date_time.iso8601_basic_short }}"
    remote_src: true
    mode: preserve
  when: remediate_cert_backup

- name: "Issue replacement certificate from Vault: {{ _cert_cn }}"
  community.hashi_vault.vault_write:
    url: "{{ vault_addr }}"
    token: "{{ vault_token }}"
    path: "{{ vault_cert_pki_path }}/issue/{{ vault_cert_role }}"
    data:
      common_name: "{{ _cert_cn }}"
      ttl: "{{ remediate_cert_ttl }}"
      format: pem
  register: _replacement_result
  no_log: true
```

**RHEL crypto-policy.** This is the highest-leverage host change: `FUTURE:PQC` plus OpenSSL groups that prefer `x25519_mlkem768`. The role restarts `sshd` and `nginx` when the policy actually changes.

```yaml
- name: Set system-wide crypto policy
  ansible.builtin.command:
    cmd: "update-crypto-policies --set {{ _target_policy }}"
  register: _policy_set_result
  when: _crypto_assessment.policy_needs_update | bool
  changed_when: "'Setting system policy' in (_policy_set_result.stdout | default(''))"

- name: Validate policy was applied
  ansible.builtin.assert:
    that:
      - _target_policy in _verify_policy.stdout
    fail_msg: >-
      Failed to apply crypto policy {{ _target_policy }}.
      Current policy: {{ _verify_policy.stdout | trim }}.
      The PQC sub-policy may not be available on this RHEL version.
```

**nginx.** Re-issues site certificates and writes `conf.d/pqc-tls.conf` with TLS 1.3 only and `ssl_ecdh_curve` set to ML-KEM hybrids. `nginx -t` runs before reload.

**sshd.** A drop-in `/etc/ssh/sshd_config.d/50-pqc-hardening.conf` prefers `mlkem768x25519-sha256` and `sntrup761x25519-sha512@openssh.com` while keeping classical KEX entries so older clients -- including the Controller -- still connect. `sshd -t` must pass. `remediate_sshd_regenerate_host_keys` defaults to `false`.

```yaml
- name: Deploy PQC SSH configuration drop-in
  ansible.builtin.copy:
    content: |
      KexAlgorithms {{ _final_kex | join(',') }}
      HostKeyAlgorithms {{ remediate_sshd_host_key_algorithms | join(',') }}
      Ciphers {{ remediate_sshd_ciphers | join(',') }}
      MACs {{ remediate_sshd_macs | join(',') }}
    dest: /etc/ssh/sshd_config.d/50-pqc-hardening.conf
    owner: root
    group: root
    mode: "0600"
  notify: Restart sshd

- name: Validate sshd configuration
  ansible.builtin.command:
    cmd: sshd -t
  register: _sshd_test
  changed_when: false
```

> **RBAC:** Split Execute by domain.
>
> Give the web team `Execute` on `pqc-remediate-nginx` only. Give the platform team `Execute` on `pqc-remediate-sshd` and `pqc-remediate-crypto-policy`. Put an approval node on those two templates in Walk/Run.

> **Warning:** Crypto-policy restarts sshd.
>
> Run `remediate_crypto_policy` in a change window. Confirm Controller can still SSH after the first host before you roll the group.

### 6. Re-scan and Prove the New Posture

**Operational Impact:** None

The last play in `remediate.yml` is tagged `always`. It re-runs `crypto_posture_snapshot` and compares readiness:

```yaml
- name: Classify post-remediation PQC readiness
  ansible.builtin.set_fact:
    pqc_ready_after: >-
      {{ (pqc_crypto_report.openssl_tls1_3_groups | default(''))
         is regex('(?i)mlkem') }}

- name: Display remediation outcome
  ansible.builtin.debug:
    msg: |
      === Remediation Complete: {{ inventory_hostname }} ===
      PQC ready before: {{ pqc_ready | default('unknown') }}
      PQC ready after:  {{ pqc_ready_after }}
      Status: {{ 'REMEDIATED' if pqc_ready_after | bool else 'REQUIRES MANUAL INTERVENTION' }}
```

Hosts that still fail usually lack OpenSSL 3.5+ (need a RHEL version that ships it) or still present classical-only TLS on a service the role does not configure. Those stay in `pqc_not_ready` for a tracked exception list rather than a fake pass.

<h2 id="validation"></h2>

## Validation

### Test

On a lab host in `pqc_targets`, run a scan that writes JSON and a CBOM. Use a machine credential, not passwords in inventory.

```bash
ansible-playbook playbooks/crypto_posture_snapshot.yml \
  -l rhel01 \
  -e pqc_write_local_report=true \
  -e pqc_write_cbom=true
```

From Controller, launch the assessment template and confirm the job succeeds:

```bash
curl -sk -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  https://controller.example.com/api/controller/v2/job_templates/compliance-scan-pqc-readiness/launch/ \
  -d '{"extra_vars": {"pqc_write_cbom": true}}' | jq '.id, .status'
```

Then dry-run remediation against the same host:

```bash
ansible-playbook playbooks/remediate.yml -l rhel01 \
  -e vault_addr=https://vault.example.com:8200 \
  -e remediate_cert_dry_run=true \
  -e remediate_crypto_dry_run=true \
  -e remediate_nginx_dry_run=true \
  -e remediate_sshd_dry_run=true
```

### Expected Result

Scan play recap is `changed=0` on targets. The control node writes `reports/rhel01.json` and `reports/cbom/rhel01.cbom.json`. A not-ready host looks like the collection unit-test fixture:

```
TASK [Show cryptographic posture report] ***************************************
ok: [rhel01] =>
  pqc_crypto_report:
    host: rhel01
    openssl_version: OpenSSL 3.0.7 1 Nov 2022
    openssl_tls1_3_groups: X25519:P-256:P-384
    crypto_policy:
      profile: DEFAULT
      fips_enabled: false

TASK [PQC readiness summary] ***************************************************
ok: [rhel01] =>
  msg: rhel01: 0.0% PQC ready (0 pass / 8 fail of 8 checks)

PLAY RECAP *********************************************************************
rhel01 : ok=24   changed=0    unreachable=0    failed=0    skipped=2
```

After a successful crypto-policy + OpenSSL 3.5 host, TLS groups include an ML-KEM hybrid and the closing debug looks like:

```
=== Remediation Complete: rhel01 ===
PQC ready before: False
PQC ready after:  True
Status: REMEDIATED
```

A PQC-ready fixture in the collection tests scores `compliance_score == 100.0` when OpenSSL reports `X25519MLKEM768` and the crypto-policy profile includes `PQC`.

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `openssl list -tls-groups` rc != 0; empty `openssl_tls1_3_groups` | OpenSSL older than the TLS-groups CLI | Treat as fail on `pqc_openssl_mlkem_support`. Upgrade to a RHEL 9 stream with OpenSSL 3.5+ before expecting `pqc_ready` |
| `Failed to apply crypto policy FUTURE:PQC` | PQC sub-policy not shipped on this RHEL version | Confirm `ls /usr/share/crypto-policies/policies/modules/PQC*`. Stay on `FUTURE` or a supported sub-policy until the module exists |
| Vault health check fails on certificate play | Vault sealed, down, or `vault_addr` wrong | Unseal Vault; verify `curl -k https://vault.example.com:8200/v1/sys/health`. Check AppRole, not an expired root token |
| `sshd configuration validation failed` | Drop-in listed a KEX the installed OpenSSH does not implement | The role already intersects requested KEX with `ssh -Q kex`. Re-run with dry-run and inspect `_final_kex`. Keep classical fallbacks |
| Controller cannot SSH after crypto-policy or sshd change | Policy/sshd no longer offers the KEX/cipher the machine credential uses | Restore `/etc/ssh/sshd_config.d/50-pqc-hardening.conf` from the `.pre-pqc.*` backup, or set `update-crypto-policies --set DEFAULT` from console, then add the Controller algorithms to the allow list |
| `401` on `install.yml` or inventory sync | Bad or expired `AAP_API_TOKEN` | Create a new token under Controller user tokens. Prefer a service account with Job Template and Inventory permissions only |
| nginx reload aborted | `nginx -t` failed after `pqc-tls.conf` | Inspect `ssl_ecdh_curve` support in that nginx build. Set `remediate_nginx_ssl_ecdh_curve` to a curve the binary accepts |

<h2 id="maturity-path"></h2>

## Maturity Path

| Maturity | Description |
|----------|-------------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6b6.png" width="20" style="vertical-align:text-bottom;"> **Crawl** | Schedule `compliance-scan-pqc-readiness` weekly. Write HTML reports and CBOMs. Do not enable remediation templates. Use the score as the Phase 1 inventory artifact |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3c3.png" width="20" style="vertical-align:text-bottom;"> **Walk** | Sync `pqc_not_ready`. Dry-run all four domains. Enable crypto-policy and nginx remediations with an approval node. Leave `remediate_sshd_regenerate_host_keys` false. Store Vault AppRole in a credential lookup |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f680.png" width="20" style="vertical-align:text-bottom;"> **Run** | Scan on a schedule, ingest CFF into the compliance dashboard, and remediate `pqc_not_ready` automatically inside a change window. Add Event-Driven Ansible on certificate expiry or a SIEM crypto finding. Replace ECDSA issuance with ML-DSA when your CA supports it |

<h2 id="related-guides"></h2>

## Related Guides

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **[Defend, Contain, Comply](README-DCC.md)** -- SIEM-triggered containment and CIS hardening on the same RHEL hosts; crypto-policy here is a cousin of that hardening stage
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **[Zero Trust Operations with Ansible](README-ZTA.md)** -- Vault already issues short-lived SSH certificates in ZTA; reuse that Vault for PQC PKI instead of standing up a second cluster
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **[Reducing Residual CVE Risk with Compensating Controls](README-CME.md)** -- scores host mitigations including crypto-policy while a patch is still in flight
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f517.png" width="20" style="vertical-align:text-bottom;"> **[AIOps automation with Ansible](README-AIOps.md)** -- event-driven plus AI workflows when you want expiry or SIEM crypto alerts to launch this scan without a human

<h2 id="summary"></h2>

## Summary

This guide automates cryptographic discovery and staged PQC remediation on RHEL 8/9 with Ansible Automation Platform. Native OS tools produce a posture fact; `normalize_pqc` and `generate_cbom` turn that fact into CFF findings and a CycloneDX CBOM you can hand to an auditor as a Phase 1 inventory. Remediation is split so certificate replacement, `FUTURE:PQC`, nginx TLS 1.3 with ML-KEM hybrids, and sshd KEX can be dry-run and approved separately. The closed loop is a second snapshot that sets `pqc_ready_after`. Crawl is scan-only. Walk adds tagged remediations and Vault AppRole lookups. Run schedules the pipeline and keeps `pqc_not_ready` as an exception queue instead of an unknown.

## Sources

- <a target="_blank" href="https://github.com/cross-logic/PQC-AAP">security.compliance_pqc_readiness -- GitHub</a>
- <a target="_blank" href="https://csrc.nist.gov/projects/post-quantum-cryptography">NIST Post-Quantum Cryptography</a>
- <a target="_blank" href="https://csrc.nist.gov/pubs/sp/1800/38/iprd">NIST SP 1800-38 -- Migration to Post-Quantum Cryptography</a>
- <a target="_blank" href="https://www.whitehouse.gov/wp-content/uploads/2026/06/M-26-15-Execution-of-the-Migration-to-Post-Quantum-Cryptography.pdf">OMB M-26-15</a>
- <a target="_blank" href="https://cyclonedx.org/capabilities/cbom/">CycloneDX Cryptography Bill of Materials</a>
- <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">Red Hat Ansible Automation Platform</a>
- <a target="_blank" href="https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/security_hardening/using-the-system-wide-cryptographic-policies_security-hardening">RHEL 9 system-wide cryptographic policies</a>
- <a target="_blank" href="https://www.vaultproject.io/">HashiCorp Vault</a>
{% endraw %}
