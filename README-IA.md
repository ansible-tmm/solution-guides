
# AI Infrastructure Automation with Ansible – Solution Guide

## Table of Contents

- [Background](#background)
- [What this solution automates?](#what-this-solution-automates)
- [Solution](#solution)
- [Solution Components](#solution-components)
- [How to Download These Collections](#how-to-download-these-collections)
- [AWS AMI Setup for RHEL AI](#aws-ami-setup-for-rhel-ai)
  - [Option 1: Subscribe via AWS Marketplace](#option-1-subscribe-via-aws-marketplace)
  - [Option 2: Create Your Own AMI](#option-2-create-your-own-ami)
- [Setting Up Inventory File](#setting-up-inventory-file)
- [Visualizing the Workflow in Ansible Automation Platform](#visualizing-the-workflow-in-ansible-automation-platform)
- [Playbooks Included in the Collections](#playbooks-included-in-the-collections)
  - [provision.yml (`infra.ai`)](#1-provisionyml-infraai)
  - [ilab.yml (`redhat.ai`)](#2-ilabyml-redhatai)
- [Pulling Sample Vars and Playbook Files](#pulling-sample-vars-and-playbook-files)
- [Variable Configuration](#variable-configuration)
- [Validating Model Deployment](#validating-model-deployment)
- [Integration with Ansible Lightspeed](#integration-with-ansible-lightspeed)
- [Final Notes](#final-notes)
- [Sources](#sources)

## Background

This solution article demonstrates how Ansible can automate the provisioning and configuration of AI infrastructure—specifically using Red Hat Enterprise Linux AI (RHEL AI) and InstructLab on AWS. It walks through how to set up infrastructure, serve models, and validate them using Ansible playbooks built with enterprise-ready content.

More broadly, deploying AI infrastructure involves provisioning compute resources, applying system configurations, installing model runtimes, and securing environments—all of which are ideal for automation. Ansible helps standardize and scale this process by:

- Automating infrastructure provisioning using cloud-native modules.
- Applying repeatable configurations to install and configure model servers (like InstructLab).
- Managing variables, playbooks, and roles as code—making automation shareable and auditable.
- Integrating with Ansible Automation Platform to operationalize deployments across teams and environments.

While this guide focuses on AWS, RHEL AI, and InstructLab, the same automation principles apply across public clouds, virtual machines, OpenShift clusters, and edge environments. Ansible collections for cloud, networking, operating systems, and AI runtimes enable teams to scale infrastructure for AI workloads reliably and consistently.

## What this solution automates?

This Ansible-based solution automates the key steps involved in setting up an AI-ready environment using RHEL AI and InstructLab on AWS. It includes:

- Provisioning infrastructure: Automatically launches EC2 instances, VPCs, subnets, and security groups using AWS modules in Ansible.
- Configuring the system: Sets up the RHEL AI instance with the required packages, configuration, and users.
- Serving an AI model: Deploys InstructLab, fetches a model, and launches an inference endpoint.
- Validation: Verifies that the model server is accessible and working using test prompts.

Together, these steps create a repeatable and auditable way to deploy AI infrastructure—from infrastructure provisioning to serving a model—using automation best practices.

## Solution Overview

This solution guide helps Ansible Automation Platform (AAP) customers automate the deployment and configuration of **RHEL AI** on **AWS** using two key Ansible collections:

- **Validated Collection**: [**infra.ai**](https://console.redhat.com/ansible/automation-hub/repo/validated/infra/ai) – Provisions RHEL AI infrastructure.
- **Certified Collection**: [**redhat.ai**](https://console.redhat.com/ansible/automation-hub/repo/published/redhat/ai) – Configures and serves an AI model on a provisioned RHEL AI host using InstructLab.


### Components

The solution leverages:

- **infra.ai** for infrastructure provisioning:
  - EC2 Instances
  - VPC
  - Subnets
  - Security Groups

- **redhat.ai** for model serving:
  - InstructLab configuration
  - Model deployment and validation

## How to Download These Collections

Before installing the collections, ensure your `ansible.cfg` file is configured to authenticate and pull content from [automation hub](https://console.redhat.com/ansible/automation-hub/token).
Then install the collections directly from automation hub:

```bash
ansible-galaxy collection install infra.ai
ansible-galaxy collection install redhat.ai
```

[Installing Ansible Collections – Documentation](https://docs.ansible.com/ansible/latest/collections_guide/collections_installing.html)

## AWS AMI Setup for RHEL AI

Provisioning requires an AMI ID for RHEL AI. Obtain it using one of these two methods:

### Option 1: Subscribe via AWS Marketplace

- Visit [Red Hat RHEL AI on AWS Marketplace](https://aws.amazon.com/marketplace).
- Subscribe to the RHEL AI AMI.
- Retrieve the AMI ID from your AWS Console in your selected region.

[Detailed instructions](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux_ai/1.4/html/installing/installing_on_aws#installing_on_aws)

### Option 2: Create Your Own AMI

- Install and configure RHEL AI manually on a supported base AWS image.
- Save your configured instance as an AMI.
- Note the AMI ID generated by AWS.

[Detailed instructions](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux_ai/1.4/html/installing/installing_on_aws#converting_image_to_ami)

Pass the obtained AMI ID into your playbook using the variable:

```yaml
rhelai_aws_rhelai_ami: ami-xxxxxxxxxxxxxxxxx
```

## Setting Up the Inventory

After provisioning the AWS instance, you need to create or sync an inventory that targets your RHEL AI host. You can do this via the Ansible CLI or Ansible Automation Controller.

### Option 1: CLI-Based Inventory

Create a static inventory file locally with the instance IP and SSH credentials:

```ini
[rhelai_servers]
<instance_ip> ansible_user=cloud-user ansible_ssh_private_key_file=~/.ssh/your_private_key.pem
```

Use this inventory when running the playbook manually:

```bash
ansible-playbook -i inventory.ini ilab.yml
```

### Option 2: Inventory Sync in Ansible Automation Controller

For workflows within Ansible Automation Platform, configure a dynamic inventory source:

1. Go to **Automation Execution -> Infrastructure -> Inventories**.
2. Add a new inventory and open it.
3. Navigate to Sources tab and Add a new source of type **Amazon EC2**.
4. Provide the correct AWS credentials.
5. Apply filters or tags (e.g., `Environment: RHEL-AI`) to scope the hosts.
6. Sync the inventory. The resulting host group (e.g., `rhelai_servers`) will be used in your job templates.

This dynamic inventory sync ensures your infrastructure is always up to date and aligns well with controller workflows.

> ✅ Tip: Use dynamic inventory sync in AAP to scale automation and keep environments consistent.


## Visualizing the Workflow in Ansible Automation Platform

You can also orchestrate this automation through **Ansible Automation Controller** by creating a workflow template. The example below shows a simple two-step workflow:

1. **Provision RHEL AI** – Launches an EC2 instance with the required network, security groups, and AMI.
2. **Configure InstructLab** – Connects to the provisioned instance and installs InstructLab along with the model-serving components.

This visual representation can help teams manage hand-offs between infrastructure and AI platform configuration, enforce approvals or triggers, and re-use this workflow across environments.

![Automation Controller Workflow Example](https://raw.githubusercontent.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/refs/heads/main/solution_images/ia-workflow-template.png)

## Included Playbooks

### 1. provision.yml (`infra.ai`)

This playbook automates infrastructure provisioning:

- Sets up AWS credentials.
- Creates a key pair.
- Provisions networking (VPC, Subnets, Security Groups).
- Launches EC2 instance with RHEL AI AMI.

### 2. ilab.yml (`redhat.ai`)

This playbook configures and serves your AI model:

- Installs and configures InstructLab.
- Downloads the required AI model.
- Starts and validates the model server.

These playbooks work sequentially to provision infrastructure and serve an AI model quickly and efficiently.

## Model selection and usage

This solution uses a Red Hat-supported large language model (LLM) designed specifically for **inference serving**. The model is automatically downloaded and served using the `redhat.ai` collection as part of the InstructLab configuration process.

Red Hat AI provides a variety of validated and optimized models for different purposes such as fine-tuning, training, or serving. You can explore the list of supported models in the [Red Hat Enterprise Linux AI documentation – Supported LLMs](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux_ai/1.4/html/building_and_maintaining_your_rhel_ai_environment/download_models#download_models).

For this solution, the focus is on **inference**—deploying a model to serve responses to user queries. You can specify the model using the following variable in your configuration:

```yaml
- name: Download model
  redhat.ai.ilab_model_download:
    name: granite-8b-lab-v1
    release: latest
    registry_url: docker://registry.redhat.io
    registry_namespace: rhelai1
    registry_username: "{{ my_registry_username }}"
    registry_password: "{{ my_registry_password }}"
```

## Pulling Sample Vars and Playbook Files

You can obtain the `sample_vars.yml`, `provision.yml`, and `ilab.yml` files directly from their respective collections:

These files are typically available in the installed collections directory:

- `~/.ansible/collections/ansible_collections/infra/ai/playbooks/`
- `~/.ansible/collections/ansible_collections/redhat/ai/playbooks/`

## Variable Configuration

All required variables for these playbooks are pre-defined in `sample_vars.yml`. Ensure this file is correctly populated to match your specific setup.

## Validating Model Deployment

Once your model is deployed and the inference server is running, you can validate that it is operational using either a curl command or the redhat.ai.completion module available in the redhat.ai Ansible content collection.

### Option 1: Using curl

Send a sample inference request:

```bash
curl -X POST http://<instance_ip>:<port>/v1/completions
  -H 'Content-Type: application/json'
  -H 'Authorization: Bearer <TOKEN>'
  -d '{
      "model": "/home/cloud-user/.cache/instructlab/models/granite-8b-lab-v1",
      "prompt": "What is the capital of France?",
      "max_tokens": 10
      }'
```

### Option 2: Using Ansible

You can also use the redhat.ai.completion module to send a prompt to the model directly from a playbook:

```yaml
- name: Ask model a question
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Ask model a question
      redhat.ai.completion:
        base_url: "http://{{ rhelai_host }}:{{ rhelai_port }}"
        validate_certs: false
        token: "{{ rhelai_api_token }}"
        prompt: "What is the capital of France?"
        model_path: "/home/cloud-user/.cache/instructlab/models/granite-8b-lab-v1"
```

This method is useful when testing from within an automated workflow or integrating into a larger playbook.

## Integration with Ansible Lightspeed

Once you have validated that the LLM is running and serving inference requests, this automated setup can act as the backend foundation for powering the Ansible Lightspeed Intelligent Assistant within Ansible Automation Platform (AAP).

This means you can use this deployment to support internal use cases where the Ansible Lightspeed intelligent assistant needs to leverage model hosted on your own infrastructure. This is particularly useful for air-gapped, privacy-sensitive, or regulated environments where using public models is not ideal.

After the model backend is ready:
	•	Follow the [Ansible Lightspeed documentation](https://docs.redhat.com/en/documentation/red_hat_ansible_lightspeed_with_ibm_watsonx_code_assistant/2.x_latest) to configure and enable the Ansible Lightspeed intelligent assistant in AAP.
	•	In the Lightspeed settings, supply your hosted LLM’s API endpoint and token as required.

This integration enables you to leverage generative AI for Ansible Automation Platform while retaining full control over your LLM infrastructure.

## Final Notes

- This solution offers a scalable foundation for automating AI infrastructure provisioning and model serving using Ansible Automation Platform.
- While the current setup focuses on RHEL AI deployments on AWS, the approach is extensible to other public clouds (Azure, GCP) and platforms like OpenShift.
- The validated (`infra.ai`) and certified (`redhat.ai`) collections used here are maintained by Red Hat and provide a reliable starting point for both experimentation and production.
- Customers can customize these playbooks to fit their organization’s infrastructure policies, integrate them into CI/CD pipelines, or use them within Automation Controller for governance and reuse.
- As Red Hat AI evolves, this automation will help ensure consistency, reduce manual effort, and streamline Day 0 to Day 2 operations for AI model serving.

We recommend checking for updates to these collections regularly on [Automation Hub](https://console.redhat.com/ansible/automation-hub/) for the latest features and improvements.

## Sources

- [Red Hat Ansible Automation Platform](https://www.redhat.com/en/technologies/management/ansible)
- [Red Hat Ansible Lightspeed](https://www.redhat.com/en/technologies/management/ansible/ansible-lightspeed)
- [Red Hat Enterprise Linux AI](https://www.redhat.com/en/products/ai/enterprise-linux-ai)