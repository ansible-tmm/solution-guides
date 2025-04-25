
# AIOps Hub - Solution Guide for Ansible Automation Platform customers

<style>
  div#toc {
    display: none;
  }
</style>

## Overview

![aiops](https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/aiops.png?raw=true)

  - [Overview](#overview-1)
  - [Background](#background-2)
  - [Solution](#solution-3)
  - [AIOps Workflow](#aiops-workflow-4)
    - [Example Workflow Diagram](#example-workflow-diagram-5)
  - [1. Event-Driven Ansible (EDA) Response](#1-event-driven-ansible-eda-response-6)
    - [Example Walkthrough for EDA Reponse](#example-walkthrough-for-eda-reponse-7)
    - [1. **IT infrastrucure event**:](#1-it-infrastrucure-event-8)
      - [ Application-Level Events](#-application-level-events-9)
      - [ Infrastructure \& Platform Events](#-infrastructure--platform-events-10)
      - [ Network \& Security Events](#-network--security-events-11)
      - [Observability-Driven Triggers](#observability-driven-triggers-12)
    - [2. **Observability tool picks up event**:](#2-observability-tool-picks-up-event-13)
      - [Filebeat](#filebeat-14)
      - [IBM Instana](#ibm-instana-15)
      - [Splunk](#splunk-16)
    - [3. **EDA sees event in message queue**](#3-eda-sees-event-in-message-queue-17)
      - [AWS SQS](#aws-sqs-18)
      - [Azure Service Bus](#azure-service-bus-19)
      - [Kafka](#kafka-20)
  - [2. Log Enrichment and Prompt Generation Workflow](#2-log-enrichment-and-prompt-generation-workflow-21)
    - [1. Capture Additional Information](#1-capture-additional-information-22)
    - [2. Red Hat AI: Analyze Incident](#2-red-hat-ai-analyze-incident-23)
      - [ Tools That Support the OpenAI-Compatible API](#-tools-that-support-the-openai-compatible-api-24)
    - [3. Notify Chat / ITSM](#3-notify-chat--itsm-25)
      - [Mattermost](#mattermost-26)
      - [ServiceNow](#servicenow-27)
      - [Slack](#slack-28)
    - [4. Build Ansible Lightspeed Job Template](#4-build-ansible-lightspeed-job-template-29)
  - [3. Remediation Workflow](#3-remediation-workflow-30)
    - [1. Lightspeed Remedation Playbook Generator](#1-lightspeed-remedation-playbook-generator-31)
    - [2. Commit Fix to Git](#2-commit-fix-to-git-32)
    - [3. Sync Project](#3-sync-project-33)
    - [4. Build Remedation Template](#4-build-remedation-template-34)
  - [4. Execute Remediation](#4-execute-remediation-35)
    - [Policy Enforcement](#policy-enforcement-36)

## Background

**AIOps** stands for *artificial intelligence* for IT operations. It refers both to a modern approach to managing IT operations and to the software systems that implement it. AIOps uses data science, big data, and machine learning to augment—or even automate—many traditionally manual IT tasks. The goal is to improve issue detection, root cause analysis, and system resolution.


<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/ai/what-is-aiops">What is AIOps? – redhat.com</a>

There are three major parts of AIOps:

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f50d.png" width="20" style="vertical-align:text-bottom;"> **Observability**
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Inference**
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/23e9.png" width="20" style="vertical-align:text-bottom;"> **Automation**

![aiops diagram](https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/aiops-circle.png?raw=true)

- **Observability**: Understanding the internal state of a system through logs, metrics, and traces.
   - <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/devops/what-is-observability">What is observability? - redhat.com </a>
- **Inference**: Using AI models to make predictions based on new data.
   - <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/ai/what-is-ai-inference">What is AI inference? - redhat.com</a>
- **Automation**: Automatically detect, respond to, and resolve IT issues.
   - <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible?sc_cid=70160000000KGIPAA4">Red Hat Ansible Automation Platform - redhat.com</a>

**Ansible Automation Platform** connects **observability** and **inference** to build **self-healing infrastructure.**

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> AIOps adoption can be incremental. You don’t need full automation on Day One. *Start small, think big!*

## Solution

What makes up the solution?

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Red Hat AI** for understanding service issues <a target="_blank" href="https://www.redhat.com/en/products/ai">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/2728.png" width="20" style="vertical-align:text-bottom;"> **Ansible Lightspeed** to generate remediation playbooks <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/ansible-lightspeed">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f501.png" width="20" style="vertical-align:text-bottom;"> **Ansible Automation Platform (AAP)** workflows for orchestration <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e1.png" width="20" style="vertical-align:text-bottom;"> **Event-Driven Ansible (EDA)** to listen to real-time service events <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible">[Link]</a>

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> EDA (Event-Driven Ansible) is part of Ansible Automation Platform.  It is referred to separately sometimes depending on the workflow.  EDA uses rulebooks to monitor events, then executes specified job templates or workflows based on the event.  Think of it simply as inputs and outputs.  EDA is an automatic way for inputs into Ansible Automation Platform, where Automation controller / Automation execution is the output (running a job template or workflow).

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3a5.png" width="20" style="vertical-align:text-bottom;"> [YouTube video (~2 min)](https://youtu.be/a3fCHd2vTXU?si=L_5jGYZFtb3SzCJq)
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e2.png" width="20" style="vertical-align:text-bottom;"> [Please consider subscribing to the Ansible Team!](https://youtube.com/ansibleautomation?sub_confirmation=1)


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

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> Could this be one workflow? Yes — but it’s broken up for review points and easier adoption.

### Example Workflow Diagram

This is a workflow **example** from our hands-on workshop **Introduction to AI-Driven Ansible Automation**

[![overview_diagram](https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/overview_diagram.png?raw=true)](https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/overview_diagram.png?raw=true)


> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> This is a high level diagram of an opinionated approach for AIOps.  This is easy customizable for a variety of IT infrastructure use-cases.

## 1. Event-Driven Ansible (EDA) Response

The first part of the AIOps workflow is the **Event-Driven Ansible (EDA) Response**.  Here is a breakdown of the four main componenets:

<a target="_blank" href="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/eda_response.png"><img src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/eda_response.png?raw=true"></a>

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

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/2753.png" width="20" style="vertical-align:text-bottom;"> Why Kafka? <a target="_blank" href="https://kafka.apache.org/">Apache Kafka</a> is a distributed streaming platform used for building real-time data pipelines and streaming applications, enabling applications to publish, consume, and process high volumes of data streams.  It is all open source and self hosted and works great for workshops.  This could be replaced by any event bus of your choosing.  Event-Driven Ansible has numerous plugins including integratrions with AWS SQS, AWS CloudTrail, Azure Service Bus, and Prometheus.


> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/2753.png" width="20" style="vertical-align:text-bottom;"> Why Filebeat? <a target="_blank" href="https://www.elastic.co/beats/filebeat">Filebeat</a> is a Lightweight shipper for logs.  It is also free and open source and works great for lab environments. Event-Driven Ansible has numerous plugins including integrations with BigPanda, Dynatrace, IBM Instana, Zabbix, and CyberArk.

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/2049.png" width="20" style="vertical-align:text-bottom;"> **Do you need an a message bus and an observability tool?** (e.g. Do you need Kafka AND Filebeat?) It depends on the particular integration.  Generally combining a message bus and an observability tool will scale the most, but it really depends on your particular use-case, amount of events, etc.  Many Observability platforms can work directly with Event-Driven Ansible just fine.

Now that you understand our workflow example, lets dive into production-grade examples:

### 1. **IT infrastrucure event**:

What kind of events are relevant in an AIOps workflow?  EDA's value proposition is that it is extremely versatile and pluggable.  This means that Ansible Automation Platform can effectivley handle any type of event.

However here is a great list of ideas:

#### <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f525.png" width="20" style="vertical-align:text-bottom;"> Application-Level Events

| Event | Source | Example Response |
|-------|--------|------------------|
| **application service crash or stopped** | `systemd`, `monit`, or Prometheus alert | Restart, notify on Slack, check last logs via journald |
| **High 5xx error rate in NGINX/Apache** | Web server logs, Prometheus metrics | Trigger Ansible to roll back a recent deployment or redirect traffic |
| **Application log shows exception spike** | Log aggregator (ELK, Loki, Datadog) | Run Ansible remediation that restarts service and clears cache |
| **Web app fails readiness check** | Kubernetes liveness/readiness probe | Reboot pod, scale another replica, or notify developer team |
| **API latency exceeds threshold** | APM tool (e.g., Dynatrace, Instana) | Provision more backend instances or restart slow services |

#### <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/2699.png" width="20" style="vertical-align:text-bottom;"> Infrastructure & Platform Events

| Event | Source | Example Response |
|-------|--------|------------------|
| **Disk space usage > 90%** | Prometheus Node Exporter, Zabbix | Clean temp files, archive logs, or extend volume |
| **High CPU load on EC2 or VM** | CloudWatch, Telegraf, etc. | Scale out VM set or move workloads |
| **OOM Kill in container** | Kubernetes Events | Restart pod, notify engineering, increase memory limits |
| **Node goes NotReady in Kubernetes** | K8s API | Cordon node, reassign pods, and open a ticket |
| **Filesystem becomes read-only** | `dmesg`, audit logs, OS-level alerts | Unmount and remount or migrate app to another host |

#### <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f310.png" width="20" style="vertical-align:text-bottom;"> Network & Security Events

| Event | Source | Example Response |
|-------|--------|------------------|
| **Interface down / Link failure** | SNMP traps, syslog | Notify NOC, run Ansible playbook to reroute traffic |
| **Unauthorized SSH attempt detected** | Fail2Ban, syslog, SIEM | Block IP, rotate SSH keys, notify SOC |
| **SSL certificate expiring soon** | Certbot, monitoring tool | Auto-renew with Let's Encrypt, push new cert with Ansible |
| **DNS resolution failures** | `systemd-resolved`, DNS logs | Switch DNS provider or fix `/etc/resolv.conf` |

#### <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;">Observability-Driven Triggers

| Event | Source | Example Response |
|-------|--------|------------------|
| **SLO breach warning (latency or error rate)** | SRE observability tool | Pre-emptively scale or rollback new features |
| **New critical error introduced in logs post-deploy** | ELK, Honeycomb, etc. | Rollback deployment via Ansible |
| **User reports spike via feedback or ticket** | ITSM tools | Use AI to correlate symptoms, gather diagnostics, and kick off a fix |


### 2. **Observability tool picks up event**:

Now that you have a great understanding of types of events, what are great examples of observability tools that can plug-in to an AIOps workflow:

#### Filebeat

<img width="200" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/beats-logo.webp?raw=true">

Filebeat is a lightweight, open-source log shipper developed by Elastic that collects and forwards logs to other parts of the Elastic Stack. It's part of the "beats" family, which includes other tools for collecting various data types. Filebeat is specifically designed for efficiently shipping log files, making it suitable for environments where resource usage needs to be minimized, like microservices or cloud-native setups.  This was used in our Ansible workshop and is not an observability tool and would also require an message bus like Kafka to operate.  It is simply forwarding logs from an end-system to a message aggeregator.

#### IBM Instana

<img width="200" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/ibm_instana.png?raw=true">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ibm/instana/">IBM Instana on Automation hub</a>

IBM Instana is a powerful observability platform designed for modern, cloud-native environments, making it an ideal foundation for AIOps strategies. It provides real-time, high-fidelity visibility into applications, services, infrastructure, and dependencies across hybrid and multicloud environments. What sets Instana apart is its ability to automatically detect changes, trace every request end-to-end, and generate context-rich alerts—enabling faster root cause analysis and proactive remediation. With built-in AI and contextual correlation, Instana helps operations teams surface anomalies, understand service impact, and trigger automation workflows, making it a key enabler for intelligent, self-healing systems in an AIOps ecosystem.

#### Splunk

<img width="200" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/splunk-logo.png?raw=true">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/namespaces/splunk/">Splunk on Automation hub</a>

Splunk is a leading data analytics and log aggregation platform that plays a pivotal role in AIOps by turning massive volumes of machine data into actionable insights. With its ability to ingest logs, metrics, traces, and events from virtually any source, Splunk provides a centralized view of system health and performance across complex IT environments. Its AIOps capabilities are driven by advanced machine learning, anomaly detection, and predictive analytics, allowing teams to proactively identify issues before they impact users. By correlating disparate signals and enriching incidents with contextual data, Splunk helps automate root cause analysis and streamline incident response workflows—making it an essential tool for organizations looking to implement intelligent, data-driven operations.


### 3. **EDA sees event in message queue**

Message queues are optional depending on the observability tool.  For example IBM Instana can work directly with Event-Driven Ansible to trigger automation jobs, or it can work with a message queue like Apache Kafka.  Here are some examples of other message queues that Ansible Automation Platform works with:

#### AWS SQS

<img width="200" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/aws-logo.png?raw=true">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/amazon/aws/">AWS on Automation hub</a>

Amazon SQS (Simple Queue Service) is a managed message queuing service from AWS that facilitates asynchronous communication between different components of a system. It allows for decoupling of applications, making them more resilient and scalable. SQS acts as a temporary repository for messages, enabling producers (applications sending messages) and consumers (applications receiving and processing messages) to communicate without direct dependencies.

#### Azure Service Bus

<img width="200" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/azure_service_bus.jpg?raw=true">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/content/eda%2Fplugins%2Fevent_source/azure_service_bus/">Azure Service Bus on Automation hub</a>

Azure Service Bus is a fully managed enterprise messaging service that provides robust message queuing and publish-subscribe capabilities, making it an excellent fit for AIOps workflows in cloud-centric environments. With support for features like message deduplication, dead-lettering, and advanced filtering, Azure Service Bus enables reliable, scalable communication between distributed systems. In an AIOps setup, it serves as a secure and resilient backbone for aggregating events and operational signals from Azure resources, applications, or third-party systems. Tools like Ansible Event-Driven Automation can subscribe to topics or queues within Service Bus to detect anomalies, failures, or changes and trigger automated remediation workflows—enabling intelligent, event-driven operations with built-in cloud-native integration.

#### Kafka

<img width="200" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/kafka_logo.webp?raw=true">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/content/eda%2Fplugins%2Fevent_source/kafka/">Kafka on Automation hub</a>

Apache Kafka is a high-throughput, fault-tolerant event streaming platform that serves as a powerful backbone for AIOps workflows by enabling real-time ingestion, aggregation, and distribution of operational events. In an AIOps context, Kafka acts as a central nervous system, collecting telemetry data, logs, alerts, and state changes from diverse sources across infrastructure and applications. This event stream can then be consumed by automation engines like Ansible Event-Driven Automation (EDA), which listen for specific patterns and trigger intelligent remediation workflows. By decoupling event producers and consumers, Kafka ensures scalability, durability, and reliability—making it ideal for building responsive, self-healing systems that operate on live operational signals.

Example rulebook for Kafka:

```yaml
---
- name: Web app issue
  hosts: all
  sources:
   - ansible.eda.kafka:
       host: service1
       port: 9092
       topic: httpd-error-logs

  rules:
    - name: apache shutdown detected
      condition: event.body.message is search("shutting down")
      action:
        run_workflow_template:
          organization: "Default"
          name: "{{ workflow_template_name | default('AI Insights and Lightspeed prompt generation') }}"

    - name: show event messages
      condition: event.body.message is defined
      action:
        debug:
          msg: "{{ event.body.message }}"

```



## 2. Log Enrichment and Prompt Generation Workflow

The second part of the AIOps workflow is the **Log Enrichment and Prompt Generation Workflow** (or for shorthand the Enrichment Workflow).  Here is a breakdown of the four main componenets:

<img src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/log_enrichment_and_prompt_generation.png?raw=true">

1. Capture Additional Information
2. Red Hat AI: Analyze Incident
3. Notify Chat / ITSM
4. Build Ansible Lightspeed Job Template

### 1. Capture Additional Information

In our AIops workshop we have an Ansible Playbook that captures additional information from the host.  If server01 reports an outage with an application (e.g. httpd), we can have Ansible collect additional information to

1. Confirm the systemd process is down
2. Collect relevant logs
3. Collect system information (operating system, memory, etc).

This process is similar to agentic workflow, where we capture information, just as we need it.

><img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;">An **agentic workflow** with AI refers to a system where an AI agent is empowered to make decisions, take actions, and pursue goals across multiple steps—often autonomously. Unlike a single API call or a static prompt, agentic workflows involve **planning, reasoning, tool use**, and possibly interacting with other agents or services. These agents maintain **state**, adjust behavior based on feedback, and operate in loops (like ReAct or AutoGPT). The goal is to replicate more human-like problem solving, where the AI isn't just responding, but actively **working through a task**. This is especially useful in AIOps, automation, and multi-step orchestration.

In this case we have a static workflow versus a fully agentic workflow, but unlike just a static LLM query, we are giving inputs from multiple sources, the event, the observability tool, system logs, and an Ansible Playbook running on the host to reterive any additional info. In the future you will see increasibly more and more ability for the operations team to allow AI tools the ability to act more autonomously.

### 2. Red Hat AI: Analyze Incident

To interface with Red Hat AI we can use the API.  Many AI tools, including Red Hat AI, are using the OpenAI API standard.

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;">The OpenAI API (/v1/completions, /v1/chat/completions) became a standard for interacting with LLMs because:
> - It was the first widely adopted commercial LLM API
> - It has a clean, JSON-based format that is easy to integrate
> - Tons of apps, SDKs, frameworks (like LangChain, AutoGen, Semantic Kernel) built around it
>

In an AIOps context, **inference** refers to the process where an AI model receives a question or input—such as a system error, log snippet, or performance metric—via an API, and returns a prediction or insight. This could include identifying root causes, classifying incidents, or suggesting remediation steps. The model has already been trained, so inference is the **real-time application** of that knowledge to live operational data. It's a key part of integrating AI into IT workflows, enabling automated, intelligent responses without human intervention.

Here is an ansible Ansible task for inference to Red Hat AI:

```yaml

    - name: Send POST request using uri module
      ansible.builtin.uri:
        url: "http://{{ rhelai_server }}:{{ rhelai_port }}/v1/completions"
        method: POST
        headers:
          accept: "application/json"
          Content-Type: "application/json"
          Authorization: "Bearer {{ rhelai_token }}"
        body:
          prompt: "{{ gpt_prompt | default('What is the capital of the USA?') }}"
          max_tokens: "{{ max_tokens | default('50') }}"
          model: "/root/.cache/instructlab/models/granite-8b-lab-v1"
          temperature: "{{ input_temperature | default(0) }}"
          top_p: "{{ input_top_p | default(1) }}"
          n: "{{ input_n | default(1) }}"
        body_format: json
        return_content: true
        status_code: 200
        timeout: 60
      register: gpt_response
```

- `prompt:` The text input or question you want the AI to respond to.
- `max_tokens:` The maximum number of tokens (words or sub-words) the AI can generate in its response.
- `model:` The path to the specific AI model used to generate the response.
- `temperature:` Controls randomness; lower values make outputs more deterministic, while higher values increase creativity.
- `top_p:` Limits the AI to sampling from the top probability mass (e.g., top 90%) for more focused outputs.
- `n:` Specifies how many different completions you want the AI to generate for the given prompt.

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> You'd want n: 1 when you're only interested in getting a single best response from the AI — which:
> - Reduces overhead: Less processing time and memory usage, especially important when running local models like Red Hat AI.
> - Simplifies parsing: You don’t have to iterate over multiple completions or choose the best one.
> - Keeps things deterministic (especially with temperature: 0): When you're aiming for predictable, repeatable automation — like in AIOps workflows — one clear response is ideal.
> - Basically, n: 1 is perfect for most automation tasks where you just need one solid, confident answer without extra noise.
>

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> Could I bring my own AI? Absolutely, since so many tools on the market use an OpenAI compatible API, you can use the same playbooks (or the task example above) to interface with the AI of your choice.


#### <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e0.png" width="20" style="vertical-align:text-bottom;"> Tools That Support the OpenAI-Compatible API

| Tool                      | Description                                                                                  |
|---------------------------|----------------------------------------------------------------------------------------------|
| **vLLM**                  | Efficient LLM serving engine with OpenAI-compatible endpoints for both completion and chat APIs |
| **llama.cpp**             | Lightweight C++ LLM inference with a `--server` mode that mimics OpenAI API                  |
| **Ollama**                | CLI + local model manager that serves LLaMA and Mistral models via OpenAI-compatible endpoints |
| **LM Studio**             | GUI for local LLMs that exposes an OpenAI-compatible endpoint                                 |
| **Text Generation WebUI**| Hugely flexible GUI for multiple models (GGUF, HF, etc), includes OpenAI API adapter          |
| **LocalAI**              | Drop-in OpenAI replacement server with multi-backend support (llama.cpp, GPT4All, etc)       |
| **DeepInfra**            | Model hosting provider offering OpenAI-compatible APIs                                       |
| **Replicate**            | Platform for hosting ML models with optional OpenAI-style API access                          |
| **Anyscale**             | Provides OpenAI-compatible APIs for hosted open models with high performance                 |


### 3. Notify Chat / ITSM

This is where we synchronize the output from Red Hat AI to another outside system.  Here some great options:

#### Mattermost

<img width="200" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/matter_most_logo.svg?raw=true">

<a target="_blank" href="https://docs.ansible.com/ansible/latest/collections/community/general/mattermost_module.html">Mattermost Documentation</a>

**Mattermost** is an open-source, self-hostable chat and collaboration platform designed for secure team communication. In AIOps workflows, it’s a powerful tool for surfacing alerts, AI-generated insights, and automated remediation steps in real time—acting as a centralized command and control interface. Unlike Slack, Mattermost is free to use and gives you full control over deployment, integrations, and data privacy. It supports robust API and webhook integrations, making it easy to connect with automation tools like Ansible or event-driven systems. This makes it a great choice for teams building transparent, automated operations workflows.  We use it in the AIOps workshop as an example similar to Slack or Microsoft Teams.

#### ServiceNow

<img width="200" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/servicenow-logo.png?raw=true">

<a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/servicenow/itsm/">ServicenNow on Automation hub</a>

ServiceNow is an enterprise-grade **IT Service Management (ITSM)** platform designed to manage and automate IT operations, workflows, and service delivery—not a chat tool. In AIOps workflows, ServiceNow acts as the system of record for incidents, changes, and problem management, often triggered or enriched by AI-driven insights. It excels at ticketing, approvals, asset management, and ensuring IT compliance across organizations. Unlike chat apps, ServiceNow is built for structured workflows, automation, and integrations with tools like monitoring systems, CMDBs, and Ansible Automation Platform. It plays a critical role in closing the loop between detection, diagnosis, and resolution in modern IT operations.

#### Slack

<img width="200" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/slack_logo.png?raw=true">

Slack is a widely adopted enterprise messaging and collaboration platform known for its polished user experience, robust integrations, and strong support ecosystem. In AIOps workflows, Slack is often used as a real-time communication hub where AI-driven alerts, diagnostics, and automation updates can be delivered directly to teams. It offers enterprise-grade features like identity management, compliance tools, and 24/7 support, making it a reliable choice for regulated and large-scale environments. Its rich API and app ecosystem allow seamless integration with platforms like ServiceNow, Ansible, and monitoring tools. While it's a paid solution, many organizations value its scalability, reliability, and enterprise-level support.

### 4. Build Ansible Lightspeed Job Template

The final piece of this workflow is creating (or updating) a Ansible Automation Platform job template with the insights we just gained from Red Hat AI.

We have a problem, such as an application outage, and we now have a solution: for example: "there is a mis-configuration on this line" and now we can use this information we gleaned and now prompt Ansible Lightspeed in the next workflow, the **Remediation workflow**.  We are basically using one AI endpoint (Red Hat AI) to help create a prompt to a second AI endpoint (Ansible Lightspeed) to create an Ansible Playbook to help remediate the issue.

<img src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/workflow_prompt.png?raw=true">

A way to do this (an opinionated way, but not the only way) is to use an <a target="_blank" href="https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/latest/html-single/using_automation_execution/index#controller-surveys-in-job-templates">Ansible Survey</a>.

In the above screenshot, the left is the prompt we will use in the next workflow, while the right is the insights we gleaned from Red Hat AI based on all the information it had.  This is a nautural breakpoint where the human can corse correct the prompt.  We will still have time to review the solution before we move it into production, but it may make sense for your IT operations team to review this prompt before we move onto Lightspeed.

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> Could we make this one workflow rather than breaking it up? YES! absolutely.  This is just showing how it is easy to adopt AIOps incrementally and add natural breakpoints to review what is happening as you adopt AI into your IT workflows.

Here is an excerpt from the Ansible Playbook used in our AIOps workshop:

```yaml
    - name: Create Job Template
      ansible.controller.job_template:
        name: "<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> Lightspeed Remediation Playbook Generator"
        job_type: "run"
        inventory: "{{ input_inventory | default('Demo Inventory') }}"
        project: "{{ input_project | default('AI-EDA') }}"
        playbook: "{{ input_playbook | default('playbooks/lightspeed_generate.yml') }}"
        credentials:
          - "{{ input_credential | default('AAP') }}"
          - "{{ vault_credential | default('ansible-vault') }}"
        validate_certs: true
        execution_environment: "Default execution environment"

    - name: Load remediation workflow template
      ansible.controller.workflow_job_template:
        name: Remediation Workflow
        organization: Default
        state: present
        survey_enabled: true
        survey_spec: "{{ lookup('template', playbook_dir + '/templates/survey.j2') }}"
```

We are able to dynamically update the survey inside the workflow by using the survey_spec.  The survey spec looks like the following:

```json
{
  "name": "Prompt Lightspeed",
  "description": "Survey for working with Ansible Lightspeed",
  "spec": [
    {
      "type": "textarea",
      "question_name": "Enter a prompt to create a remediation playbook?",
      "question_description": "This prompt will be used with Ansible Lightspeed to automatically generate an Ansible Playbook",
      "variable": "lightspeed_prompt",
      "required": true,
      "default": "For all hosts, use become true,  Remove line that contains InvalidDirectiveHere from /etc/httpd/conf/httpd.conf and restart httpd"
    },
    {
      "type": "textarea",
      "question_name": "This box shows the prompt generated from our Workflow job template",
      "question_description": "This area shows you that AI was able to understand the error and create a prompt for Ansible Lightspeed.",
      "variable": "ai_lightspeed_prompt",
      "required": false,
      "default": "{{ gpt_generated_prompt }}"
    }
  ]
}
```

Now everytime the first workflow **Log Enrichment and Prompt Generation Workflow** runs, the second workflow **Remediation Workflow** automatically has its survey updates to be relevant to that workflow. This is doing **Config as Code** using the ansible.controller content collection.

Please consider using the <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/validated/infra/aap_configuration/">AAP Configuration Collection on Automation hub.</a> This content collection simplifies interactions for Ansible Automation Platform.

## 3. Remediation Workflow

The third part of the AIOps workflow is the **Remediation Workflow**.  This workflow will take a prompt from the previous workflow, allow the human operator to customize this prompt, then build an Ansible Playbook to remediate the issue, sync this to git and build a job template that will run this playbook for the final step.

 Here is a breakdown of the four main componenets:

<img src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/remediation_workflow.png?raw=true">

1. Lightspeed Remedation Playbook Generator
2. Commit Fix to Git
3. Sync Project
4. Build Remedation Template

### 1. Lightspeed Remedation Playbook Generator

Ansible Lightspeed also has an API.  We can communicate to this API similarly as we do with Red Hat AI solutions.  Here is an example task:

```yaml
    - name: Send request to AI API
      ansible.builtin.uri:
        url: "{{ input_lightspeed_url | default('https://c.ai.ansible.redhat.com/api/v0/ai/generations/') }}"
        method: POST
        headers:
          Content-Type: "application/json"
          Authorization: "Bearer {{ lightspeed_wca_token }}"
        body_format: json
        body:
          text: "{{ lightspeed_prompt }}"
      register: response
```

The API will respond with the Ansible Playbook as part of the payload under the `playbook` keyword.  You can see the response in the Job Output window:

<img src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/return_playbook.png?raw=true">

### 2. Commit Fix to Git

One the Ansible Playbook is retreieve from Ansible Lightspeed, we need to store it in a Git repo.  We can use the <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/scm/">Ansible SCM</a> (source control management) content collection to easily publish the content to any specified repo.

Here is an excerpt from our AIOps Workshop:

```yaml
    - name: Commit and push final version of playbook to Gitea
      ansible.scm.git_publish:
        path: "{{ repository['path'] }}"
        token: "{{ gitea_token }}"
```

### 3. Sync Project

This is a special node type inside the Workflow Visualizer that will sync a Project.  Since we just pushed this Ansible Playbook to Git we need to sync the Project to update and retrieve this playbook to be used in an Ansible Job Template.  Here is a screen shot from the Workflow visualizer showing the **Project Sync**:

<img src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/workflow_node_type.png?raw=true">

### 4. Build Remedation Template

The final job template inside this workflow is creating a new job template with the newly created Ansible Playbook.  We can use the `ansible.controller` content collection to dynamically build this.  Here is an example:

```yaml
    - name: Create Job Template
      ansible.controller.job_template:
        name: "<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f527.png" width="20" style="vertical-align:text-bottom;"><img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/2705.png" width="20" style="vertical-align:text-bottom;"> Execute HTTPD Remediation"
        job_type: "run"
        inventory: "{{ input_inventory | default('lab-inventory') }}"
        project: "{{ input_project | default('Lightspeed-Playbooks') }}"
        playbook: "{{ input_playbook | default('lightspeed-response.yml') }}"
        credential: "{{ input_credential | default('lab-credential') }}"
        validate_certs: true
        execution_environment: "Default execution environment"
        become_enabled: true
        ask_limit_on_launch: true
```

> <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> Could we just run the new playbook within this workflow and fixed it right now? YES, but you may want to run the playbook during a specific change window.  This is another natural breakpoint where you can add more guard rails before you push an Ansible job into production.  Now that you have the Job Template queued up, you can run it whenever you want.


## 4. Execute Remediation

The final Job Template that fixes the issue

### Policy Enforcement

<a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/automated-policy-as-code">https://www.redhat.com/en/technologies/management/ansible/automated-policy-as-code</a>



---

<img width="400" src="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/aap_logo.png?raw=true">
