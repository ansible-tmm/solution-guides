
# AIOps Hub - Solution Guide for Ansible Automation Platform customers

## Overview

![aiops](assets/images/aiops.png)



---

## Background

**AIOps** stands for *artificial intelligence* for IT operations. It refers both to a modern approach to managing IT operations and to the software systems that implement it. AIOps uses data science, big data, and machine learning to augment—or even automate—many traditionally manual IT tasks. The goal is to improve issue detection, root cause analysis, and system resolution.


📖 <a target="_blank" href="https://www.redhat.com/en/topics/ai/what-is-aiops">What is AIOps? – redhat.com</a>

There are three major parts of AIOps:

- **Observability**
- **Inference**
- **Automation**

![aiops diagram](assets/images/aiops-circle.png)

- **Observability**: Understanding the internal state of a system through logs, metrics, and traces.

- **Inference**: Using AI models to make predictions based on new data.

- **Automation**: Automatically detect, respond to, and resolve IT issues. *Ansible Automation Platform* connects observability and inference to build self-healing infrastructure.

> ⚠️ AIOps adoption can be incremental. You don’t need full automation on Day One. *Start small, think big!*

---

## Lab Environment

[![lab_topology](../assets/images/lab_topology.png)](../assets/images/lab_topology.png)

- RHEL node with Apache (`httpd`)
- Filebeat monitors Apache logs
- Kafka acts as the event transport
- EDA listens to Kafka, launches workflows
- Red Hat AI infers incident context
- Ansible Lightspeed generates remediation playbooks
- Gitea manages playbooks via Git
- AAP executes jobs and workflows

> 💡 **EDA (Event-Driven Ansible)** is a part of AAP that uses rulebooks to monitor events and execute job templates or workflows. Think: inputs (events) → EDA → outputs (job runs).
>

# Solution

In this lab, you will build an intelligent, self-healing automation workflow using:

- 🧠 **Red Hat AI** for understanding service issues
- ✨ **Ansible Lightspeed** to generate remediation playbooks
- 🔁 **Ansible Automation Platform (AAP)** workflows for orchestration
- 📡 **Event-Driven Ansible (EDA)** to listen to real-time service events

The goal is to showcase how **automation + AI** can be used to detect, analyze, and remediate application failures **without writing any playbooks manually**.

🎥 [YouTube video (~2 min)](https://youtu.be/a3fCHd2vTXU?si=L_5jGYZFtb3SzCJq)
📢 [Please consider subscribing to the Ansible Team!](https://youtube.com/ansibleautomation?sub_confirmation=1)

---

## AIOps Workflow

An AIOps workflow has four (4) parts:

1. **Event-Driven Ansible (EDA) Response**
   Respond to an event, such as a systemd application outage

2. **Log Enrichment and Prompt Generation Workflow**
   AAP coordinates with Red Hat AI, notifies Mattermost, auto-creates a Job Template

3. **Remediation Workflow**
   Generates a playbook via Ansible Lightspeed, syncs it to Git, builds another Job Template

4. **Execute HTTPD Remediation**
   The final Job Template that fixes the Apache outage

> 💡 Could this be one workflow? Yes — but it’s broken up for review points and easier adoption.

### Full Workflow Diagram

[![overview_diagram](../assets/images/overview_diagram.png)](../assets/images/overview_diagram.png)

> ❓ **Why Mattermost?**
> An open-source alternative to Slack/MS Teams. Used for this lab, but can be swapped for your favorite chat or ITSM system (e.g. *ServiceNow*).

> ❓ **Why Gitea?**
> Lightweight self-hosted Git. Replaceable with *GitHub*, *GitLab*, etc. Ideal for hands-on workshops.

> ❓ **Why Kafka?**
> Open-source event streaming platform. Replaceable with other buses like AWS SQS, Azure Service Bus, Prometheus, etc. EDA supports many integrations.

---

## I need more details!

![give me more](../assets/images/more.png)

Woh! Calm down there home slice! Here's a full breakdown of every step:

[![workflow_diagram](../assets/images/workflow_diagram.png)](../assets/images/workflow_diagram.png)

Each module breaks down its part of the workflow. Together, we'll make AIOps easy to adopt and scale 🎉

---

## Access & Credentials

You're already logged in as `{ssh_user}` — no setup needed.
All lab content is preconfigured and ready to go.

---

## What's Next?

Let’s get started 🚀

Click the link below to proceed to the next section.

![aap_logo](../assets/images/aap_logo.png)
