
# AIOps Hub - Solution Guide for Ansible Automation Platform customers

## Overview

![aiops](assets/images/aiops.png)


- [AIOps Hub - Solution Guide for Ansible Automation Platform customers](#aiops-hub---solution-guide-for-ansible-automation-platform-customers)
  - [Overview](#overview)
  - [Background](#background)
- [Solution](#solution)
  - [AIOps Workflow](#aiops-workflow)
    - [Example Workflow Diagram](#example-workflow-diagram)
  - [1. Event-Driven Ansible (EDA) Response](#1-event-driven-ansible-eda-response)
    - [Example Walkthrough for EDA Reponse](#example-walkthrough-for-eda-reponse)
    - [1. **IT infrastrucure event**:](#1-it-infrastrucure-event)
      - [🔥 Application-Level Events](#-application-level-events)
      - [⚙️ Infrastructure \& Platform Events](#️-infrastructure--platform-events)
      - [🌐 Network \& Security Events](#-network--security-events)
      - [💡Observability-Driven Triggers](#observability-driven-triggers)
    - [2. **Observability tool picks up event**:](#2-observability-tool-picks-up-event)
      - [Filebeat](#filebeat)
      - [IBM Instana](#ibm-instana)
      - [Splunk](#splunk)
    - [3. **EDA sees event in message queue**](#3-eda-sees-event-in-message-queue)
      - [AWS SQS](#aws-sqs)
      - [Azure Service Bus](#azure-service-bus)
      - [Kafka](#kafka)
  - [2. Log Enrichment and Prompt Generation Workflow](#2-log-enrichment-and-prompt-generation-workflow)
  - [3. Remediation Workflow](#3-remediation-workflow)
  - [4. Execute HTTPD Remediation](#4-execute-httpd-remediation)


## Background

**AIOps** stands for *artificial intelligence* for IT operations. It refers both to a modern approach to managing IT operations and to the software systems that implement it. AIOps uses data science, big data, and machine learning to augment—or even automate—many traditionally manual IT tasks. The goal is to improve issue detection, root cause analysis, and system resolution.


📖 <a target="_blank" href="https://www.redhat.com/en/topics/ai/what-is-aiops">What is AIOps? – redhat.com</a>

There are three major parts of AIOps:

- 🔍 **Observability**
- 🧠 **Inference**
- ⏩ **Automation**

![aiops diagram](assets/images/aiops-circle.png)

- **Observability**: Understanding the internal state of a system through logs, metrics, and traces.
   - 📖 <a target="_blank" href="https://www.redhat.com/en/topics/devops/what-is-observability">What is observability? - redhat.com </a>
- **Inference**: Using AI models to make predictions based on new data.
   - 📖 <a target="_blank" href="https://www.redhat.com/en/topics/ai/what-is-ai-inference">What is AI inference? - redhat.com</a>
- **Automation**: Automatically detect, respond to, and resolve IT issues.
   - 📖 <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible?sc_cid=70160000000KGIPAA4">Red Hat Ansible Automation Platform - redhat.com</a>

**Ansible Automation Platform** connects **observability** and **inference** to build **self-healing infrastructure.**

> ⚠️ AIOps adoption can be incremental. You don’t need full automation on Day One. *Start small, think big!*

# Solution

What makes up the solution?

- 🧠 **Red Hat AI** for understanding service issues <a target="_blank" href="https://www.redhat.com/en/products/ai">[Link]</a>
- ✨ **Ansible Lightspeed** to generate remediation playbooks <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/ansible-lightspeed">[Link]</a>
- 🔁 **Ansible Automation Platform (AAP)** workflows for orchestration <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">[Link]</a>
- 📡 **Event-Driven Ansible (EDA)** to listen to real-time service events <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible">[Link]</a>

> 💡 EDA (Event-Driven Ansible) is part of Ansible Automation Platform.  It is referred to separately sometimes depending on the workflow.  EDA uses rulebooks to monitor events, then executes specified job templates or workflows based on the event.  Think of it simply as inputs and outputs.  EDA is an automatic way for inputs into Ansible Automation Platform, where Automation controller / Automation execution is the output (running a job template or workflow).

- 🎥 [YouTube video (~2 min)](https://youtu.be/a3fCHd2vTXU?si=L_5jGYZFtb3SzCJq)
- 📢 [Please consider subscribing to the Ansible Team!](https://youtube.com/ansibleautomation?sub_confirmation=1)


## AIOps Workflow

An AIOps workflow has four (4) parts:

1. **Event-Driven Ansible (EDA) Response**

   Respond to an event, such as a systemd application outage.  This falls under the **Observability** part of the AIOps workflow.  EDA allows us to plug-in **observability** to an **automation** workflow.

2. **Log Enrichment and Prompt Generation Workflow**

   AAP coordinates with Red Hat AI, notifies your chat application or ITSM (IT service management tool).  This falls under the **Inference** part of the AIOps workflow.  Again, Ansible Automation Platform ties this into an **automation** workflow.

3. **Remediation Workflow**

   Generates a playbook via Ansible Lightspeed, syncs it to Git, builds another Job Template.  This also falls uner **Interference** part of the AIOps workflow.  For this solution we are using one AI LLM endpoint (Red hat AI) to figure out what the issue is and diagnose it, and one AI LLM endpoint to create an Ansible Playbook to remediate the issue.  This is considered a A **multi-LLM workflow**, as we are using 2 or more LLM endpoints within our workflow.

4. **Execute  Remediation**

   The final Job Template that fixes the issue on your IT infrastrucure.  This is executing the Ansible Playbook that was generated in the previous workflow.  This falls under the **automation** part of AIOps and wraps up our self healing infrastructure use-case..

> 💡 Could this be one workflow? Yes — but it’s broken up for review points and easier adoption.

### Example Workflow Diagram

This is a workflow **example** from our hands-on workshop **Introduction to AI-Driven Ansible Automation**

[![overview_diagram](assets/images/overview_diagram.png)](assets/images/overview_diagram.png)


> 💡 This is a high level diagram of an opinionated approach for AIOps.  This is easy customizable for a variety of IT infrastructure use-cases.

## 1. Event-Driven Ansible (EDA) Response

The first part of the AIOps workflow is the **Event-Driven Ansible (EDA) Response**.  Here is a breakdown of the four main componenets:

<a target="_blank" href="assets/images/eda_response.png"><img src="assets/images/eda_response.png"></a>

  1. IT infrastrucure event
  2. Observability tool picks up event
  3. EDA sees event in message queue
  4. Execute Enrichment workflow

### Example Walkthrough for EDA Reponse

In our hands-on workshop we simulate an **httpd** application outage.  This is how the workflow works:

  1. **IT infrastrucure event**: The student will break httpd using a Job Template
  2. **Observability tool picks up event**: Filebeat monitors Apache logs, Kafka acts as the event transport
  3. **EDA sees event in message queue**: EDA listens to Kafka, launches automation workflows
  4. **Execute Enrichment workflow** Ansible Automation Platform kicks off part 2, **Log Encrichment and Prompt Generation Workflow**

> ❓ Why Kafka? <a target="_blank" href="https://kafka.apache.org/">Apache Kafka</a> is a distributed streaming platform used for building real-time data pipelines and streaming applications, enabling applications to publish, consume, and process high volumes of data streams.  It is all open source and self hosted and works great for workshops.  This could be replaced by any event bus of your choosing.  Event-Driven Ansible has numerous plugins including integratrions with AWS SQS, AWS CloudTrail, Azure Service Bus, and Prometheus.


> ❓ Why Filebeat? <a target="_blank" href="https://www.elastic.co/beats/filebeat">Filebeat</a> is a Lightweight shipper for logs.  It is also free and open source and works great for lab environments. Event-Driven Ansible has numerous plugins including integrations with BigPanda, Dynatrace, IBM Instana, Zabbix, and CyberArk.

> ⁉️ **Do you need an a message bus and an observability tool?** (e.g. Do you need Kafka AND Filebeat?) It depends on the particular integration.  Generally combining a message bus and an observability tool will scale the most, but it really depends on your particular use-case, amount of events, etc.  Many Observability platforms can work directly with Event-Driven Ansible just fine.

Now that you understand our workflow example, lets dive into production-grade examples:

### 1. **IT infrastrucure event**:

What kind of events are relevant in an AIOps workflow?  EDA's value proposition is that it is extremely versatile and pluggable.  This means that Ansible Automation Platform can effectivley handle any type of event.

However here is a great list of ideas:

#### 🔥 Application-Level Events

| Event | Source | Example Response |
|-------|--------|------------------|
| **application service crash or stopped** | `systemd`, `monit`, or Prometheus alert | Restart, notify on Slack, check last logs via journald |
| **High 5xx error rate in NGINX/Apache** | Web server logs, Prometheus metrics | Trigger Ansible to roll back a recent deployment or redirect traffic |
| **Application log shows exception spike** | Log aggregator (ELK, Loki, Datadog) | Run Ansible remediation that restarts service and clears cache |
| **Web app fails readiness check** | Kubernetes liveness/readiness probe | Reboot pod, scale another replica, or notify developer team |
| **API latency exceeds threshold** | APM tool (e.g., Dynatrace, Instana) | Provision more backend instances or restart slow services |

#### ⚙️ Infrastructure & Platform Events

| Event | Source | Example Response |
|-------|--------|------------------|
| **Disk space usage > 90%** | Prometheus Node Exporter, Zabbix | Clean temp files, archive logs, or extend volume |
| **High CPU load on EC2 or VM** | CloudWatch, Telegraf, etc. | Scale out VM set or move workloads |
| **OOM Kill in container** | Kubernetes Events | Restart pod, notify engineering, increase memory limits |
| **Node goes NotReady in Kubernetes** | K8s API | Cordon node, reassign pods, and open a ticket |
| **Filesystem becomes read-only** | `dmesg`, audit logs, OS-level alerts | Unmount and remount or migrate app to another host |

#### 🌐 Network & Security Events

| Event | Source | Example Response |
|-------|--------|------------------|
| **Interface down / Link failure** | SNMP traps, syslog | Notify NOC, run Ansible playbook to reroute traffic |
| **Unauthorized SSH attempt detected** | Fail2Ban, syslog, SIEM | Block IP, rotate SSH keys, notify SOC |
| **SSL certificate expiring soon** | Certbot, monitoring tool | Auto-renew with Let's Encrypt, push new cert with Ansible |
| **DNS resolution failures** | `systemd-resolved`, DNS logs | Switch DNS provider or fix `/etc/resolv.conf` |

#### 💡Observability-Driven Triggers

| Event | Source | Example Response |
|-------|--------|------------------|
| **SLO breach warning (latency or error rate)** | SRE observability tool | Pre-emptively scale or rollback new features |
| **New critical error introduced in logs post-deploy** | ELK, Honeycomb, etc. | Rollback deployment via Ansible |
| **User reports spike via feedback or ticket** | ITSM tools | Use AI to correlate symptoms, gather diagnostics, and kick off a fix |


### 2. **Observability tool picks up event**:

Now that you have a great understanding of types of events, what are great examples of observability tools that can plug-in to an AIOps workflow:

#### Filebeat

<img width="200" src="assets/images/beats-logo.webp">

Filebeat is a lightweight, open-source log shipper developed by Elastic that collects and forwards logs to other parts of the Elastic Stack. It's part of the "beats" family, which includes other tools for collecting various data types. Filebeat is specifically designed for efficiently shipping log files, making it suitable for environments where resource usage needs to be minimized, like microservices or cloud-native setups.  This was used in our Ansible workshop and is not an observability tool and would also require an message bus like Kafka to operate.  It is simply forwarding logs from an end-system to a message aggeregator.

#### IBM Instana

<img width="200" src="assets/images/ibm_instana.png">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ibm/instana/">IBM Instana on Automation hub</a>

IBM Instana is a powerful observability platform designed for modern, cloud-native environments, making it an ideal foundation for AIOps strategies. It provides real-time, high-fidelity visibility into applications, services, infrastructure, and dependencies across hybrid and multicloud environments. What sets Instana apart is its ability to automatically detect changes, trace every request end-to-end, and generate context-rich alerts—enabling faster root cause analysis and proactive remediation. With built-in AI and contextual correlation, Instana helps operations teams surface anomalies, understand service impact, and trigger automation workflows, making it a key enabler for intelligent, self-healing systems in an AIOps ecosystem.

#### Splunk

<img width="200" src="assets/images/splunk-logo.png">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/namespaces/splunk/">Splunk on Automation hub</a>

Splunk is a leading data analytics and log aggregation platform that plays a pivotal role in AIOps by turning massive volumes of machine data into actionable insights. With its ability to ingest logs, metrics, traces, and events from virtually any source, Splunk provides a centralized view of system health and performance across complex IT environments. Its AIOps capabilities are driven by advanced machine learning, anomaly detection, and predictive analytics, allowing teams to proactively identify issues before they impact users. By correlating disparate signals and enriching incidents with contextual data, Splunk helps automate root cause analysis and streamline incident response workflows—making it an essential tool for organizations looking to implement intelligent, data-driven operations.


### 3. **EDA sees event in message queue**

Message queues are optional depending on the observability tool.  For example IBM Instana can work directly with Event-Driven Ansible to trigger automation jobs, or it can work with a message queue like Apache Kafka.  Here are some examples of other message queues that Ansible Automation Platform works with:

#### AWS SQS

<img width="200" src="assets/images/aws-logo.png">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/amazon/aws/">AWS on Automation hub</a>

Amazon SQS (Simple Queue Service) is a managed message queuing service from AWS that facilitates asynchronous communication between different components of a system. It allows for decoupling of applications, making them more resilient and scalable. SQS acts as a temporary repository for messages, enabling producers (applications sending messages) and consumers (applications receiving and processing messages) to communicate without direct dependencies.

#### Azure Service Bus

<img width="200" src="assets/images/azure_service_bus.jpg">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/content/eda%2Fplugins%2Fevent_source/azure_service_bus/">Azure Service Bus on Automation hub</a>

Azure Service Bus is a fully managed enterprise messaging service that provides robust message queuing and publish-subscribe capabilities, making it an excellent fit for AIOps workflows in cloud-centric environments. With support for features like message deduplication, dead-lettering, and advanced filtering, Azure Service Bus enables reliable, scalable communication between distributed systems. In an AIOps setup, it serves as a secure and resilient backbone for aggregating events and operational signals from Azure resources, applications, or third-party systems. Tools like Ansible Event-Driven Automation can subscribe to topics or queues within Service Bus to detect anomalies, failures, or changes and trigger automated remediation workflows—enabling intelligent, event-driven operations with built-in cloud-native integration.

#### Kafka

<img width="200" src="assets/images/kafka_logo.webp">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/content/eda%2Fplugins%2Fevent_source/kafka/">Kafka on Automation hub</a>

Apache Kafka is a high-throughput, fault-tolerant event streaming platform that serves as a powerful backbone for AIOps workflows by enabling real-time ingestion, aggregation, and distribution of operational events. In an AIOps context, Kafka acts as a central nervous system, collecting telemetry data, logs, alerts, and state changes from diverse sources across infrastructure and applications. This event stream can then be consumed by automation engines like Ansible Event-Driven Automation (EDA), which listen for specific patterns and trigger intelligent remediation workflows. By decoupling event producers and consumers, Kafka ensures scalability, durability, and reliability—making it ideal for building responsive, self-healing systems that operate on live operational signals.



## 2. Log Enrichment and Prompt Generation Workflow
   AAP coordinates with Red Hat AI, notifies Mattermost, auto-creates a Job Template

- Red Hat AI infers incident context

## 3. Remediation Workflow
   Generates a playbook via Ansible Lightspeed, syncs it to Git, builds another Job Template

- Ansible Lightspeed generates remediation playbooks
- Gitea manages playbooks via Git


## 4. Execute HTTPD Remediation
   The final Job Template that fixes the Apache outage

- AAP executes jobs and workflows


---

![aap_logo](assets/images/aap_logo.png)
