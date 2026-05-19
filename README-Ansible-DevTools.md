# Ansible Development Tools - Solution Guide

## Overview

Setting up a consistent Ansible development environment across a team is harder than it sounds. Developers spend hours installing and configuring individual tools, only to find that versions conflict, linting rules differ, or molecule tests pass on one workstation but fail on another. These inconsistencies slow down onboarding, introduce subtle bugs, and make it difficult to enforce quality standards across automation content.

**Ansible Development Tools (ADT)** solves this by bundling essential CLI tools into a single, versioned package that runs on a developer's workstation -- no Ansible Automation Platform installation required. ADT is available through multiple delivery methods to fit any workflow, from a developer laptop to a cloud-based workspace.

This guide walks through four approaches to install and run ADT, compares their trade-offs, and helps you choose the right one for your team.

---

- [Ansible Development Tools - Solution Guide](#ansible-development-tools---solution-guide)
  - [Overview](#overview)
  - [Background](#background)
  - [Solution](#solution)
    - [What's in the Bundle](#whats-in-the-bundle)
    - [Who Benefits](#who-benefits)
    - [Recommended Resources](#recommended-resources)
  - [Prerequisites](#prerequisites)
    - [Ansible Automation Platform](#ansible-automation-platform)
    - [System Requirements](#system-requirements)
  - [Installation Methods](#installation-methods)
    - [Method A: Python Package (uv)](#method-a-python-package-uv)
    - [Method B: RPM (Red Hat Subscription)](#method-b-rpm-red-hat-subscription)
    - [Method C: Dev Container (VS Code)](#method-c-dev-container-vs-code)
    - [Method D: Red Hat OpenShift Dev Spaces](#method-d-red-hat-openshift-dev-spaces)
  - [Comparison](#comparison)
  - [Validation](#validation)
    - [Verify the Installation](#verify-the-installation)
    - [Quick Smoke Test](#quick-smoke-test)
    - [Troubleshooting](#troubleshooting)
  - [Maturity Path](#maturity-path)
  - [Related Guides](#related-guides)
  - [Sources](#sources)

---

## Background

The Ansible content lifecycle -- **Create, Test, Deploy** -- requires a set of specialized tools at each stage. Historically, developers installed these tools individually, leading to version mismatches, broken integrations, and "works on my machine" issues.

ADT addresses this by providing a single installable package (or container image) that bundles known-good versions of all essential tools. Whether you install via uv/pip, RPM, or use a containerized environment, you get the same toolchain with the same integration guarantees.

> **Why a bundle instead of individual installs?**
>
> The tools in ADT are tightly integrated -- `ansible-lint` feeds into the VS Code extension, `molecule` uses `ansible-navigator` and `podman` under the hood, and `ansible-creator` scaffolds projects pre-configured for all of them. Installing them separately risks version conflicts and broken integrations.

---

## Solution

### What's in the Bundle

ADT includes ten tools covering the full content lifecycle:

| Stage | Tool | Purpose |
|-------|------|---------|
| **Create** | `ansible-creator` | Scaffold collections, roles, playbooks, and plugins |
| **Create** | `ansible-dev-environment` | pip-like install for Ansible collections in virtual environments |
| **Create** | `ansible-core` | Core automation engine |
| **Test** | `ansible-lint` | Static analysis for playbooks, roles, and collections |
| **Test** | `molecule` | Integration testing with ephemeral infrastructure |
| **Test** | `pytest-ansible` | pytest plugin for testing module and plugin Python code |
| **Test** | `tox-ansible` | Test matrix across Python and ansible-core versions |
| **Deploy** | `ansible-builder` | Build execution environments (container images) |
| **Deploy** | `ansible-galaxy` | Install collections and roles from Galaxy or Automation Hub (included with `ansible-core`) |
| **Deploy** | `ansible-navigator` | TUI for running and troubleshooting automation with EEs |
| **Deploy** | `ansible-sign` | Sign and verify Ansible project contents |

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|----------------|
| **Automation Developer** | Spending time assembling and maintaining individual tools instead of writing automation | A single install that provides all tools in known-good, compatible versions |
| **Platform Engineer / SRE** | Inconsistent environments across developers causing "works on my machine" issues | Containerized workspaces that guarantee identical toolchains for every developer |
| **Automation Architect** | Enforcing development standards and testing practices across multiple teams | Standardized tooling that embeds linting profiles, testing frameworks, and signing into the workflow |
| **Engineering Manager** | Slow onboarding -- new developers take days to set up a working environment | One-click workspace provisioning via Dev Spaces or dev containers with zero local setup |

### Recommended Resources

- **Source code:** [ansible/ansible-dev-tools](https://github.com/ansible/ansible-dev-tools) on GitHub
- **Documentation (upstream):** [Ansible Development Tools](https://docs.ansible.com/projects/dev-tools/) official docs
- **Documentation (downstream):** [Developing automation content (AAP 2.6)](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/developing_automation_content/devtools-intro) on Red Hat docs
- **Container image:** [community-ansible-dev-tools](https://github.com/ansible/community-ansible-dev-tools/pkgs/container/community-ansible-dev-tools) on GHCR
- **VS Code extension:** [Ansible extension for VS Code](https://marketplace.visualstudio.com/items?itemName=redhat.ansible)
- **Community:** [Matrix #devtools:ansible.com](https://matrix.to/#/#devtools:ansible.com)
- **Hands-on workshop:** Coming soon

---

## Prerequisites

### Ansible Automation Platform

- **uv/pip/container methods:** No AAP subscription required -- these use the upstream community packages.
- **RPM method:** Requires an AAP or Ansible Developer subscription and RHEL 9 registered with Red Hat Subscription Manager.
- **Dev Spaces method:** Requires an OpenShift cluster with Red Hat OpenShift Dev Spaces operator installed.

### System Requirements

| Requirement | uv/pip | RPM | Dev Container | Dev Spaces |
|-------------|-----|-----|---------------|------------|
| **Python** | 3.10+ | 3.10+ (included in RHEL 9+) | N/A (in container) | N/A (in container) |
| **OS** | Linux, macOS, WSL | RHEL 9 | Any (VS Code + container runtime) | Browser only |
| **Container runtime** | Optional (for molecule, builder) | Optional (for molecule, builder) | Docker or Podman | Managed by OpenShift |
| **Disk space** | ~500 MB | ~500 MB | ~2 GB (image) | Managed by cluster |
| **Subscription** | None | Red Hat AAP or Ansible Developer | None | OpenShift + Dev Spaces |

---

## Installation Methods

### Method A: Python Package (uv)

**Operational Impact:** None -- local workstation only

**Best for:** Individual developers, quick setup on Linux/macOS/WSL, CI pipelines.

**Step 1:** Install [uv](https://docs.astral.sh/uv/) if you don't have it:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Step 2:** Create a virtual environment and install ADT:

```bash
uv venv ~/ansible-dev-venv
source ~/ansible-dev-venv/bin/activate
uv add ansible-dev-tools
```

**Step 3:** Verify the installation:

```bash
adt --version
```

> **Tip:** Always use a virtual environment.
>
> Installing ADT system-wide can conflict with OS-packaged Python modules. On macOS 14+ and newer Linux distributions, the system Python is externally managed (PEP 668) and direct installs will fail. Using `uv` with a venv avoids this entirely.

> **Tip:** `pip` works too.
>
> If you prefer `pip`, replace `uv venv` with `python3 -m venv` and `uv add` with `pip install`. The rest of the workflow is identical.

**Upgrading:**

```bash
uv add --upgrade ansible-dev-tools
```

**Pinning a specific version:**

```bash
uv add ansible-dev-tools==26.4.6
```

---

### Method B: RPM (Red Hat Subscription)

**Operational Impact:** None -- local workstation only

**Best for:** Enterprise environments running RHEL with Red Hat subscriptions, air-gapped networks with Satellite.

**Step 1:** Register your system and enable a repository that includes ADT. Two subscription options are available:

```bash
# Option 1: Ansible Automation Platform subscription (AAP 2.6, RHEL 9)
sudo subscription-manager repos \
  --enable ansible-automation-platform-2.6-for-rhel-9-x86_64-rpms

# Option 2: Ansible Developer subscription (Developer 1.3, RHEL 9)
sudo subscription-manager repos \
  --enable ansible-developer-1.3-for-rhel-9-x86_64-rpms
```

> **Tip:** Choose the right subscription for your use case.
>
> The **Ansible Developer** subscription provides the development tools without bundling the full AAP platform -- this is often more appropriate for developer workstations. The **AAP** subscription includes the dev tools alongside the full platform components.

**Step 2:** Install ADT:

```bash
sudo dnf install ansible-dev-tools
```

**Step 3:** Verify the installation:

```bash
adt --version
```

> **Why RPM over uv/pip?**
>
> The RPM packages are built and tested by Red Hat, receive security errata through the standard RHEL advisory process, and are supported under a Red Hat subscription. This is the recommended method for enterprises that need vendor-backed support and predictable update cycles.

**Available repositories:**

Both subscriptions provide repos for RHEL 9 across four architectures: `x86_64`, `aarch64`, `ppc64le`, and `s390x`. Replace the architecture in the repo name to match your system:

- **Ansible Automation Platform:** `ansible-automation-platform-{version}-for-rhel-9-{arch}-rpms` (versions: 2.6, 2.5)
- **Ansible Developer:** `ansible-developer-{version}-for-rhel-9-{arch}-rpms` (versions: 1.3, 1.2)

---

### Method C: Dev Container (VS Code)

**Operational Impact:** None -- local workstation only

**Best for:** Teams wanting a consistent, reproducible development environment without managing Python installations. Works on any OS that runs VS Code and a container runtime.

Pre-built container images with all ADT tools, the Ansible VS Code extension, and nested Podman support are available in two variants:

- **Upstream (community):** `ghcr.io/ansible/community-ansible-dev-tools:latest`
- **Downstream (Red Hat supported):** `registry.redhat.io/ansible-automation-platform-26/ansible-dev-tools-rhel9` (requires [Red Hat registry authentication](https://access.redhat.com/RegistryAuthentication))

**Step 1:** Install prerequisites:

- [VS Code](https://code.visualstudio.com/)
- [Ansible extension for VS Code](https://marketplace.visualstudio.com/items?itemName=redhat.ansible) (`redhat.ansible`)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) (`ms-vscode-remote.remote-containers`)
- A container runtime: [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [Podman Desktop](https://podman-desktop.io/)

**Step 2:** Add a devcontainer to your project using one of these methods:

**Option A: CLI.** Run `ansible-creator` to scaffold devcontainer files into an existing project:

```bash
ansible-creator add resource devcontainer /path/to/your/project
```

This generates a `.devcontainer/` directory with both Docker and Podman configurations.

**Option B: VS Code UI.** Open the command palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run **Ansible: Add devcontainer configuration**. The Ansible extension generates the same `.devcontainer/` directory.

**Option C: Manual.** Create `.devcontainer/devcontainer.json` in your project:

```json
{
  "name": "Ansible Dev Tools",
  "image": "ghcr.io/ansible/community-ansible-dev-tools:latest",
  "customizations": {
    "vscode": {
      "extensions": [
        "redhat.ansible"
      ],
      "settings": {
        "ansible.validation.lint.enabled": true,
        "ansible.executionEnvironment.containerEngine": "podman"
      }
    }
  },
  "remoteUser": "podman"
}
```

**Step 3:** Open your project in VS Code, and when prompted, click **Reopen in Container** (or run the command `Dev Containers: Reopen in Container` from the command palette).

**Step 4:** Open a terminal in VS Code and verify:

```bash
adt --version
```

> **Tip:** Nested Podman is supported.
>
> The container image supports nested Podman, so you can run `molecule test` and `ansible-builder build` inside the dev container without additional configuration.

**Running the container image directly (without VS Code):**

```bash
podman run -it --rm \
  --cap-add=SYS_ADMIN \
  --cap-add=SYS_RESOURCE \
  --device "/dev/fuse" \
  --hostname=ansible-dev-container \
  --name=ansible-dev-container \
  --security-opt "apparmor=unconfined" \
  --security-opt "label=disable" \
  --security-opt "seccomp=unconfined" \
  --user=root \
  --userns=host \
  -v $PWD:/workdir \
  ghcr.io/ansible/community-ansible-dev-tools:latest
```

---

### Method D: Red Hat OpenShift Dev Spaces

**Operational Impact:** Medium -- requires an OpenShift cluster with Dev Spaces operator

**Best for:** Enterprise teams wanting centralized, browser-based development environments with zero local setup. Ideal for onboarding, workshops, and environments where developers cannot install software on their workstations.

Dev Spaces provides a full VS Code environment running in the browser, backed by an OpenShift cluster. All tools, extensions, and project sources are defined in a `devfile.yaml` -- a declarative workspace specification.

**Step 1:** Ensure your OpenShift cluster has the Dev Spaces operator installed and configured.

**Step 2:** Log into the Dev Spaces dashboard:

```
https://devspaces.<your-openshift-ingress-domain>
```

**Step 3:** Import a workspace from a Git repository. Paste the URL of a repository containing a `devfile.yaml`, for example:

```
https://github.com/rhpds/ansible-dev-tools-workspace.git
```

Click **Create & Open**. The workspace provisions automatically with all ADT tools pre-installed.

**Step 4:** Once the VS Code interface loads in your browser, open a terminal and verify:

```bash
adt --version
```

**Example devfile.yaml:**

```yaml
schemaVersion: 2.2.2
metadata:
  name: ansible-dev-tools-workspace
components:
  - name: tooling-container
    container:
      image: ghcr.io/ansible/community-ansible-dev-tools:latest
      memoryRequest: 2Gi
      memoryLimit: 4Gi
      cpuRequest: 500m
      cpuLimit: 1000m
      env:
        - name: SHELL
          value: /bin/bash
        - name: ADT_CONTAINER_ENGINE
          value: podman
```

> **Why Dev Spaces?**
>
> Unlike local dev containers, Dev Spaces runs entirely in the cloud. Developers only need a browser. The platform administrator controls the image, resource limits, and access -- ensuring every developer gets an identical, governed environment. This also enables features like rootless nested containers via OpenShift user namespaces, which are difficult to configure on local workstations.

**Key capabilities in Dev Spaces:**

| Feature | Details |
|---------|---------|
| **Browser-based VS Code** | Full IDE experience with no local install |
| **Nested containers** | Rootless Podman for molecule tests and EE builds |
| **Workspace-as-code** | `devfile.yaml` defines tools, repos, and resources declaratively |
| **Multi-user** | Each developer gets an isolated workspace on shared infrastructure |
| **Preloaded extensions** | Ansible VS Code extension with lint, navigator, and creator integration |
| **Git integration** | OAuth2 for GitHub/GitLab, SSH key forwarding |

---

## Comparison

| Dimension | uv/pip | RPM | Dev Container | Dev Spaces |
|-----------|--------|-----|---------------|------------|
| **Setup time** | ~5 min | ~5 min | ~10 min (first pull) | ~5 min (workspace start) |
| **Local install required** | Python 3.10+ | RHEL + subscription | VS Code + container runtime | Browser only |
| **Team consistency** | Low (varies by env) | Medium (same RPM version) | High (same image) | Highest (centrally managed) |
| **Nested containers** | N/A (use host runtime) | N/A (use host runtime) | Yes (with capabilities) | Yes (OCP user namespaces) |
| **Offline / air-gapped** | PyPI mirror | Satellite | Registry mirror | Internal registry |
| **Vendor support** | Community | Red Hat (AAP sub) | Community | Red Hat (OCP + Dev Spaces) |
| **CI/CD integration** | Excellent | Good (RHEL runners) | Excellent (GitHub Codespaces) | Limited (workspace-oriented) |
| **Cost** | Free | AAP subscription | Free (+ runtime license) | OCP + Dev Spaces subscription |

> **Start here:** Choose by use case.
>
> For individual exploration, use **uv/pip**. For team standardization, use **dev containers**. For enterprise governance and zero-trust environments, use **Dev Spaces**. For RHEL shops with Red Hat subscriptions that need supported packages, use **RPM**.

---

## Validation

### Verify the Installation

Regardless of the installation method, run:

```bash
adt --version
```

**Expected output** (versions may vary):

```
ansible-builder                 3.1.0
ansible-core                    2.18.6
ansible-creator                 25.4.0
ansible-dev-environment         25.4.0
ansible-dev-tools               26.4.6
ansible-lint                    25.4.0
ansible-navigator               25.4.0
ansible-sign                    0.1.1
molecule                        25.4.0
pytest-ansible                  25.4.0
tox-ansible                     25.4.0
```

### Quick Smoke Test

Scaffold a collection and run lint to confirm the full toolchain works:

```bash
ansible-creator init collection testns.testcol --init-path /tmp/testcol
cd /tmp/testcol
ansible-lint
```

**Expected result:** `ansible-lint` should complete with no errors on the scaffolded collection.

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `command not found: adt` | Virtual environment not activated | Run `source ~/ansible-dev-venv/bin/activate` |
| `uv add` or `pip install` fails with dependency conflicts | System Python has conflicting packages or is externally managed (PEP 668) | Use `uv venv` to create a clean virtual environment. On macOS 14+, `uv` handles PEP 668 automatically |
| `dnf install` says package not found | AAP repo not enabled or subscription not attached | Run `subscription-manager repos --list \| grep ansible` to verify repo availability |
| Dev container fails to start | Container runtime not running | Start Docker Desktop or Podman Desktop, then retry |
| Molecule tests fail with "permission denied" | Missing container capabilities for nested Podman | Add `--cap-add=SYS_ADMIN --cap-add=SYS_RESOURCE --device /dev/fuse` flags |
| Dev Spaces workspace stuck starting | Resource limits exceeded or image pull failure | Check OpenShift events with `oc get events -n <workspace-ns>` |
| `ansible-lint` shows different results across team | Different ADT versions installed | Pin the version (`uv add ansible-dev-tools==26.4.6`) or use container-based methods |

---

## Maturity Path

| Maturity | What You Do | Automation Autonomy |
|----------|-------------|---------------------|
| **Crawl** | Install ADT via uv/pip on individual workstations. Run `ansible-lint` manually. Use `ansible-creator` to scaffold projects. | Manual -- developer runs tools on demand |
| **Walk** | Standardize on dev containers or RPMs. Add `ansible-lint` and `molecule` to CI pipelines. Share a common `.devcontainer/` across repos. | Semi-automated -- CI enforces standards, developers use consistent environments |
| **Run** | Deploy Dev Spaces for the entire team. Define workspace images and devfiles centrally. Integrate `ansible-sign` for content verification. Build custom EEs with `ansible-builder` in CI/CD. | Fully governed -- platform team manages tooling, signing, and testing centrally |

> **Start with Crawl.** Get one developer comfortable with ADT, then scale to the team. The container-based methods (Walk/Run) build on the same tools -- the investment in learning the CLI transfers directly.

---

## Related Guides

- **Execution Environments:** See the [Ansible Builder documentation](https://docs.ansible.com/projects/dev-tools/container/) for building custom EEs on top of the ADT container image.
- **Content Testing:** See [Molecule documentation](https://ansible.readthedocs.io/projects/molecule/) for comprehensive testing strategies with ADT.
- **Content Signing:** See [ansible-sign documentation](https://docs.ansible.com/projects/sign/) for signing and verifying Ansible content in CI/CD.
- **Dev Spaces Administration:** See the [Red Hat OpenShift Dev Spaces docs](https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/) for cluster setup and operator configuration.
- **Hands-on workshop:** Coming soon

---

## Sources

**Upstream (community)**

- [Ansible Development Tools documentation](https://docs.ansible.com/projects/dev-tools/)
- [ansible-dev-tools on GitHub](https://github.com/ansible/ansible-dev-tools)
- [community-ansible-dev-tools container](https://docs.ansible.com/projects/dev-tools/container/)
- [OpenShift Dev Spaces with ADT](https://docs.ansible.com/projects/dev-tools/devspaces/)
- [ansible-dev-tools on PyPI](https://pypi.org/project/ansible-dev-tools/)

**Downstream (Red Hat product documentation)**

- [Ansible development tools overview (AAP 2.6)](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/developing_automation_content/devtools-intro)
- [Installing Ansible development tools (AAP 2.6)](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/developing_automation_content/installing-devtools)
- [Using Ansible development workspaces (AAP 2.6)](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html-single/using_ansible_development_workspaces_for_automation_content_development/index)

**Other**

- [Solution Guides Best Practices](https://ansible-tmm.github.io/solution-guides/README-best-practices)

---

*Copyright 2026 Red Hat, Inc.*
