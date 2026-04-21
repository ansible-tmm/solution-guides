{% raw %}
# High-Availability Ansible Automation Platform with EDB PostgreSQL Active-Passive DR - Solution Guide <!-- omit in toc -->

<style>
  div#toc {
    display: none;
  }
</style>

## Overview

When Ansible Automation Platform becomes mission-critical infrastructure -- orchestrating network changes, managing security compliance, or coordinating multi-cloud deployments -- downtime is not an option. A database failure, datacenter outage, or unplanned maintenance window can halt automation across the enterprise, blocking change tickets, delaying deployments, and leaving teams unable to respond to incidents.

This guide demonstrates how to deploy Red Hat Ansible Automation Platform 2.6 with a **multi-datacenter Active-Passive disaster recovery architecture** using EDB Postgres Advanced Server and EDB Failover Manager (EFM). The result is a resilient automation platform capable of surviving datacenter failures with **Recovery Time Objective (RTO) under 5 minutes** and **Recovery Point Objective (RPO) under 5 seconds** -- ensuring automation continuity for mission-critical operations.

**Business value:** Guaranteed automation availability for mission-critical workflows. Reduced risk of extended outages blocking change management, compliance enforcement, or incident response. Automated failover eliminates manual intervention during datacenter failures, reducing downtime from hours (manual DR procedures) to minutes (automated database promotion and AAP activation).

**Technical value:** Proven enterprise topology for production AAP deployments. Streaming replication with sub-5-second RPO protects against data loss. EFM-managed automated failover orchestrates database promotion and AAP service activation without operator intervention. Full implementation roadmap from infrastructure provisioning through testing and production cutover.

- [Background](#background)
- [Solution](#solution)
- [Prerequisites](#prerequisites)
- [Multi-Datacenter DR Architecture](#multi-datacenter-dr-architecture)
- [Solution Walkthrough](#solution-walkthrough)
  - [Phase 1: Infrastructure Preparation](#phase-1-infrastructure-preparation)
  - [Phase 2: Database Cluster Setup](#phase-2-database-cluster-setup)
  - [Phase 3: AAP Installation](#phase-3-aap-installation)
  - [Phase 4: Integration and Automation](#phase-4-integration-and-automation)
  - [Phase 5: Testing and Validation](#phase-5-testing-and-validation)
  - [Phase 6: Production Cutover](#phase-6-production-cutover)
- [Validation](#validation)
- [Operational Runbook](#operational-runbook)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)

---

## Background

### Why Disaster Recovery Matters for Automation Platforms

Ansible Automation Platform has evolved from a convenient automation tool to mission-critical enterprise infrastructure. Organizations use AAP to orchestrate network changes across thousands of devices, enforce compliance policies on production servers, coordinate multi-cloud deployments, and automate incident response. When AAP is unavailable, these critical workflows stop.

A database failure in a single-datacenter AAP deployment creates cascading impact:

- **Change management blocked** -- teams cannot execute approved automation, delaying deployments and configuration changes
- **Compliance drift** -- scheduled enforcement playbooks do not run, allowing systems to drift out of policy
- **Incident response delayed** -- on-call engineers cannot trigger remediation playbooks during outages
- **Audit trail interrupted** -- automation activity logs are incomplete, creating compliance gaps

Traditional backup-and-restore approaches offer Recovery Time Objectives measured in hours, not minutes. Restoring a multi-database AAP deployment from backup requires coordinating database recovery, verifying data consistency across four separate databases (controller, hub, EDA, gateway), and validating service health before resuming automation. This is unacceptable for platforms supporting mission-critical workflows.

### Active-Passive Multi-Datacenter DR Architecture

Active-Passive disaster recovery deploys a complete AAP stack in two datacenters:

- **Active site (DC1)** -- production AAP services handle all automation traffic; PostgreSQL primary database serves all read-write operations
- **Passive site (DC2)** -- AAP services remain stopped; PostgreSQL designated primary receives streaming replication from DC1 but does not accept connections

When DC1 fails, EDB Failover Manager (EFM) automatically promotes the DC2 database to primary and triggers a post-promotion script that starts AAP services in DC2. The global load balancer detects DC2 health checks passing and redirects traffic. Total failover time: under 5 minutes.

This architecture extends Red Hat's tested Container Enterprise Topology -- an 8-VM, multi-component design for high-scale AAP deployments -- into a multi-datacenter configuration. Each datacenter follows Red Hat's validated single-datacenter model, with cross-datacenter database replication and automated failover orchestration providing disaster recovery capability.

### EDB Postgres: Enterprise-Grade Database Platform

[EDB Postgres Advanced Server](https://www.enterprisedb.com/products/edb-postgres-advanced-server) extends PostgreSQL with enterprise features required for mission-critical AAP deployments:

- **Streaming replication** with synchronous local standbys and asynchronous cross-datacenter standbys delivers sub-5-second RPO
- **EDB Failover Manager (EFM)** provides automated database promotion, virtual IP failover, and post-promotion script execution for application service activation
- **Barman backup integration** supports point-in-time recovery and WAL archiving to S3/NFS for disaster scenarios requiring historical data restoration
- **Performance optimizations** including connection pooling compatibility, query tuning extensions, and workload profiling tools
- **Oracle compatibility** (optional) for organizations migrating from Oracle-based automation platforms

EDB is a trusted PostgreSQL partner with deep integration into Red Hat's ecosystem. EFM's post-promotion script capability enables coordinated database-and-application failover, ensuring AAP services start only after the database is ready to accept connections.

---

## Solution

### Components

**Ansible Automation Platform -- the automation layer:**

- **[Red Hat Ansible Automation Platform 2.6](https://www.redhat.com/en/technologies/management/ansible)** -- containerized deployment on RHEL 9.4+ using Podman
- **AAP Container Enterprise Topology** -- 8-VM component architecture per datacenter (2 gateway, 2 controller, 2 hub, 2 EDA)
- **Redis HA** -- colocated on gateway, hub, and EDA nodes for session storage and job queue management

**EDB PostgreSQL -- the database layer:**

- **[EDB Postgres Advanced Server 16](https://www.enterprisedb.com/products/edb-postgres-advanced-server)** -- 3-node cluster per datacenter with streaming replication
- **[EDB Failover Manager (EFM)](https://www.enterprisedb.com/docs/efm/latest/)** -- automated database promotion, VIP management, and post-promotion script execution
- **[Barman](https://pgbarman.org/)** -- continuous WAL archiving and point-in-time recovery to S3/NFS

**Infrastructure:**

- **HAProxy** -- database connection routing from AAP services to PostgreSQL VIP
- **Global Load Balancer** -- F5, HAProxy, or Route53 with health-check-based routing to active datacenter
- **Site-to-site VPN or Direct Connect** -- low-latency WAN connectivity between datacenters (< 100ms latency required)

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| **IT Ops Engineer / SRE** | AAP downtime blocks critical automation; manual DR procedures require coordinating database restore, service startup, and health validation across 16+ VMs | Automated failover orchestration via EFM; tested recovery procedures with concrete validation commands; complete operational runbook for daily health checks and emergency failover |
| **Automation Architect** | Uncertainty about how to design production-ready AAP for mission-critical use cases; existing single-datacenter deployments lack disaster recovery capability | Production-validated reference architecture based on Red Hat's Container Enterprise Topology; detailed component specifications, network topology, and firewall rules; clear guidance on when to use this 26-VM enterprise design vs. smaller growth topologies |
| **IT Manager / Director** | Business justification required for DR investment; inability to commit to SLA targets without proven recovery procedures | Measurable RTO/RPO targets (5 minutes / 5 seconds); infrastructure scale and resource planning guidance; implementation roadmap with clear phase gates from planning through production cutover |

### Recommended Demos and Self-Paced Labs

- [Red Hat Ansible Automation Platform Documentation](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/)
- [EDB Failover Manager Documentation](https://www.enterprisedb.com/docs/efm/latest/)

---

## Prerequisites

### Red Hat Ansible Automation Platform

**Ansible Automation Platform 2.6+** -- required for Container Enterprise Topology support and unified containerized installer.

### Operating System and Runtime

- **RHEL 9.4+** on all AAP component VMs and PostgreSQL database nodes
- **Podman** (bundled with RHEL) for AAP container runtime
- **Python >= 3.9** for Ansible Core

### External Systems

| System | Required | Examples |
|--------|----------|----------|
| EDB Postgres Advanced Server | Yes | EDB subscription or trial license |
| EDB Failover Manager (EFM) | Yes | Bundled with EDB Postgres Advanced Server |
| Global Load Balancer | Yes | F5 BIG-IP, HAProxy, AWS Route53, Azure Traffic Manager |
| WAL Archive Storage | Yes | S3, Azure Blob, NFS |
| Site-to-site connectivity | Yes | VPN or Direct Connect with < 100ms latency |

**Operational Impact:** High during implementation phases; Medium for ongoing operations; High during failover/failback procedures.

### Infrastructure Requirements

**Total Resource Footprint:**

- **26 VMs** total (13 per datacenter)
  - 8 AAP component VMs per DC (2 gateway, 2 controller, 2 hub, 2 EDA)
  - 3 PostgreSQL VMs per DC
  - 1 HAProxy + 1 Barman per DC
- **68 vCPU, 272GB RAM per datacenter**
- **500GB SSD per PostgreSQL node** (3000 IOPS minimum)
- **WAN bandwidth:** 100 Mbps minimum, 1 Gbps recommended for replication

> **Note:** This is Red Hat's enterprise-scale Container Topology extended to multi-datacenter Active-Passive. For smaller deployments, see the 3-node Growth Topology variant referenced in the source architecture documentation.

### Cost and Resource Notes

- **EDB licensing:** Contact EDB for Advanced Server and EFM pricing
- **AAP subscription:** Standard AAP pricing applies; no additional cost for multi-datacenter deployment
- **Infrastructure:** VM costs scale linearly -- this is a 2x infrastructure investment compared to single-datacenter deployment
- **Storage:** S3/Azure Blob for WAL archiving incurs storage and transfer costs

---

## Multi-Datacenter DR Architecture

### High-Level Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                        GLOBAL LOAD BALANCER                            │
│                      (F5 / HAProxy / Route53)                          │
│                    https://aap.example.com                             │
│                                                                        │
│  Health Checks: /api/v2/ping/ every 10s                                │
│  Active-Passive Routing: DC1 (Priority 100) → DC2 (Priority 50)        │
└──────────────┬────────────────────────────────┬────────────────────────┘
               │ (Active - 100% traffic)        │ (Passive - 0% traffic)
               │                                │
┌──────────────▼─────────────────┐   ┌──────────▼──────────────────────┐
│      DATACENTER 1 (Active)     │   │    DATACENTER 2 (Standby)       │
│                                │   │                                 │
│  ┌──────────────────────────┐  │   │  ┌──────────────────────────┐   │
│  │  AAP Component Layer     │  │   │  │  AAP Component Layer     │   │
│  │  (8 VMs - Active)        │  │   │  │  (8 VMs - STOPPED)       │   │
│  │                          │  │   │  │                          │   │
│  │  gateway1-dc1            │  │   │  │  gateway1-dc2            │   │
│  │  gateway2-dc1            │  │   │  │  gateway2-dc2            │   │
│  │    + Redis colocated     │  │   │  │    + Redis (stopped)     │   │
│  │                          │  │   │  │                          │   │
│  │  controller1-dc1         │  │   │  │  controller1-dc2         │   │
│  │  controller2-dc1         │  │   │  │  controller2-dc2         │   │
│  │    (dedicated VMs)       │  │   │  │    (stopped)             │   │
│  │                          │  │   │  │                          │   │
│  │  hub1-dc1                │  │   │  │  hub1-dc2                │   │
│  │  hub2-dc1                │  │   │  │  hub2-dc2                │   │
│  │    + Redis colocated     │  │   │  │    + Redis (stopped)     │   │
│  │                          │  │   │  │                          │   │
│  │  eda1-dc1                │  │   │  │  eda1-dc2                │   │
│  │  eda2-dc1                │  │   │  │  eda2-dc2                │   │
│  │    + Redis colocated     │  │   │  │    + Redis (stopped)     │   │
│  └──────────────────────────┘  │   │  └──────────────────────────┘   │
│  ┌───────────────────────────┐ │   │  ┌───────────────────────────┐  │
│  │  HAProxy Load Balancer    │ │   │  │  HAProxy Load Balancer    │  │
│  │  vip-dc1.example.com      │ │   │  │  vip-dc2.example.com      │  │
│  └────────┬──────────────────┘ │   │  └────────┬──────────────────┘  │
│           │                    │   │           │                     │         
│  ┌────────▼───────────────────┐│   │  ┌────────▼───────────────────┐ │
│  │ PostgreSQL Cluster (3)     ││   │  │ PostgreSQL Cluster (3)     │ │
│  │ (EDB Postgres Advanced 16) ││   │  │ (EDB Postgres Advanced 16) │ │
│  │                            ││   │  │                            │ │
│  │ pg-dc1-1 (PRIMARY)         ││   │  │ pg-dc2-1 (STANDBY/DP)      │ │
│  │   - awx                    ││   │  │   - awx (replica)          │ │
│  │   - automationhub          ││   │  │   - automationhub          │ │
│  │   - automationedacontroller││   │  │   - automationedacontroller│ │
│  │   - automationgateway      ││   │  │   - automationgateway      │ │
│  │                            ││   │  │                            │ │
│  │ pg-dc1-2 (STANDBY)         ││   │  │ pg-dc2-2 (STANDBY)         │ │
│  │ pg-dc1-3 (STANDBY)         ││   │  │ pg-dc2-3 (STANDBY)         │ │
│  │                            ││   │  │                            │ │
│  │ VIP: 10.1.2.100 (EFM)      ││   │  │ VIP: 10.2.2.100 (EFM)      │ │
│  └────────┬───────────────────┘│   │  └────────┬───────────────────┘ │
│           │                    │   │           │                     │
│  ┌────────▼──────────────────┐ │   │  ┌────────▼───────────────────┐ │
│  │ Barman Backup Server      │ │   │  │ Barman Backup Server       │ │
│  │ + WAL Archive (NFS/S3)    │ │   │  │ + WAL Archive (NFS/S3)     │ │
│  └───────────────────────────┘ │   │  └────────────────────────────┘ │
└───────────┬────────────────────┘   └────────────┬────────────────────┘
            │                                     │
            │      Streaming Replication (SSL)    │
            │      5432 (direct or VPN tunnel)    │
            └─────────────────────────────────────┘
                     (Asynchronous)
```

### Data Flow During Normal Operations (DC1 Active)

```
User → GLB → HAProxy(DC1) → AAP Containers(DC1) → VIP(DC1) → PostgreSQL PRIMARY(DC1)
                                                                      │
                                    ┌─────────────────────────────────┼───────────────┐
                                    │                                 │               │
                                    ▼                                 ▼               ▼
                            PG Standby DC1-2                  PG Standby DC1-3    S3/Barman
                                                                      │
                                                        Streaming Replication (WAN)
                                                                      │
                                                                      ▼
                                                          PG Designated Primary DC2-1
                                                                      │
                                            ┌─────────────────────────┼──────────────┐
                                            │                         │              │
                                            ▼                         ▼              ▼
                                    PG Standby DC2-2          PG Standby DC2-3   S3/Barman
```

### Automated Failover Sequence (DC1 Failure)

```
1. EFM Detects Primary Failure (pg-dc1-1)
   Time: T+0s

2. EFM Promotes DC2 Designated Primary (pg-dc2-1)
   Command: pg_ctl promote
   Time: T+15s

3. EFM Updates VIP (DC2)
   VIP 10.2.2.100 moved to pg-dc2-1
   Time: T+20s

4. EFM Executes Post-Promotion Script
   Script starts AAP containers in DC2
   Time: T+25s to T+180s

5. Global Load Balancer Detects DC2 Healthy
   Health checks to DC2: PASSING
   Route traffic to DC2
   Time: T+200s

6. Failover Complete
   RTO Target: <300s (5 minutes)
   Actual RTO: ~240s (4 minutes)
```

### Component Specifications

#### AAP Component VMs (Per Datacenter)

| Component | Specification | Count | Resource per VM | Total Resources |
|-----------|--------------|-------|-----------------|-----------------|
| **Platform Gateway** | RHEL 9.4+, Podman + Redis | 2 | 4 vCPU, 16GB RAM, 60GB disk | 8 vCPU, 32GB RAM |
| **Automation Controller** | RHEL 9.4+, Podman | 2 | 4 vCPU, 16GB RAM, 60GB disk | 8 vCPU, 32GB RAM |
| **Automation Hub** | RHEL 9.4+, Podman + Redis | 2 | 4 vCPU, 16GB RAM, 60GB disk | 8 vCPU, 32GB RAM |
| **Event-Driven Ansible** | RHEL 9.4+, Podman + Redis | 2 | 4 vCPU, 16GB RAM, 60GB disk | 8 vCPU, 32GB RAM |
| **HAProxy DB Router** | RHEL 9.4+, HAProxy | 1 | 2 vCPU, 8GB RAM, 40GB disk | 2 vCPU, 8GB RAM |
| **Total AAP Infrastructure** | - | **9 VMs** | - | **34 vCPU, 136GB RAM** |

#### PostgreSQL Database Cluster (Per Datacenter)

| Role | Count | Specification |
|------|-------|---------------|
| **Primary + 2 Standby (DC1)** | 3 | 8 vCPU, 32GB RAM, 500GB SSD |
| **Designated Primary + 2 Standby (DC2)** | 3 | 8 vCPU, 32GB RAM, 500GB SSD |

#### AAP Databases (4 databases per PostgreSQL instance)

```sql
-- Database Layout (AAP 2.6 official database names)
CREATE DATABASE awx OWNER aap;                          -- 50GB (main controller database)
CREATE DATABASE automationhub OWNER aap;                -- 20GB (content/collections)
CREATE DATABASE automationedacontroller OWNER aap;      -- 10GB (event-driven automation)
CREATE DATABASE automationgateway OWNER aap;            -- 5GB (platform gateway)
```

#### Network Topology

```
DC1 Network:
  - AAP Subnet:       10.1.1.0/24
    - gateway1-dc1:     10.1.1.11    gateway2-dc1:     10.1.1.12
    - controller1-dc1:  10.1.1.13    controller2-dc1:  10.1.1.14
    - hub1-dc1:         10.1.1.15    hub2-dc1:         10.1.1.16
    - eda1-dc1:         10.1.1.17    eda2-dc1:         10.1.1.18
    - haproxy-db-dc1:   10.1.1.20

  - Database Subnet:  10.1.2.0/24
    - pg-dc1-1:         10.1.2.21    pg-dc1-2:         10.1.2.22
    - pg-dc1-3:         10.1.2.23
    - Database VIP:     10.1.2.100 (EFM managed)

DC2 Network:
  - AAP Subnet:       10.2.1.0/24
    - gateway1-dc2:     10.2.1.11    gateway2-dc2:     10.2.1.12
    - controller1-dc2:  10.2.1.13    controller2-dc2:  10.2.1.14
    - hub1-dc2:         10.2.1.15    hub2-dc2:         10.2.1.16
    - eda1-dc2:         10.2.1.17    eda2-dc2:         10.2.1.18
    - haproxy-db-dc2:   10.2.1.20

  - Database Subnet:  10.2.2.0/24
    - pg-dc2-1:         10.2.2.21    pg-dc2-2:         10.2.2.22
    - pg-dc2-3:         10.2.2.23
    - Database VIP:     10.2.2.100 (EFM managed)

WAN Connectivity:
  - Type: Site-to-Site VPN or Direct Connect
  - Bandwidth: 100 Mbps minimum, 1 Gbps recommended
  - Latency: < 100ms required for streaming replication
  - Encryption: IPsec or TLS
```

> **Why HAProxy instead of pgBouncer?** AAP 2.6 has specific connection pooling requirements that make HAProxy the recommended approach for database connection routing. HAProxy routes AAP containers to the EFM-managed PostgreSQL VIP without connection pooling. See the source architecture documentation's "HAProxy vs pgBouncer Architectural Analysis" for complete design rationale.

---

## Solution Walkthrough

### Phase 1: Infrastructure Preparation

**Operational Impact:** None -- provisioning and configuration only

**Duration:** Week 1-2

**Tasks:**

1. Provision VMs (26 total)
   - DC1: 8 AAP VMs + 3 PostgreSQL + 1 HAProxy + 1 Barman
   - DC2: 8 AAP VMs + 3 PostgreSQL + 1 HAProxy + 1 Barman
2. Install RHEL 9.4+ on all nodes
3. Configure network (VLANs, firewall rules, VPN between DCs)
4. Install Podman on AAP component VMs
5. Configure storage (SSD for databases, ensure 3000 IOPS minimum)

**Network firewall rules required:**

```bash
# User Access (GLB → HAProxy)
Source: 0.0.0.0/0
Dest: 10.1.1.100, 10.2.1.100
Port: 443/tcp

# HAProxy → Platform Gateway
Source: 10.1.1.10, 10.2.1.10
Dest: 10.1.1.11-12, 10.2.1.11-12
Port: 80/443

# Platform Gateway → AAP Components
Source: 10.1.1.11-12, 10.2.1.11-12
Dest: 10.1.1.13-18, 10.2.1.13-18
Port: 8080/8443 (Controller), 8081/8444 (Hub), 8082/8445 (EDA)

# AAP Components → PostgreSQL (via HAProxy)
Source: 10.1.1.0/24, 10.2.1.0/24
Dest: 10.1.1.20, 10.2.1.20
Port: 5432/tcp

# HAProxy → PostgreSQL VIP
Source: 10.1.1.20, 10.2.1.20
Dest: 10.1.2.100, 10.2.2.100
Port: 5432/tcp

# PostgreSQL Replication (DC1 → DC2)
Source: 10.1.2.21-23
Dest: 10.2.2.21-23
Port: 5432/tcp

# EFM Cluster Communication
Source: 10.1.2.0/24, 10.2.2.0/24
Dest: 10.1.2.0/24, 10.2.2.0/24
Port: 7800-7810/tcp
```

---

### Phase 2: Database Cluster Setup

**Operational Impact:** Low -- database installation and replication setup, no production traffic

**Duration:** Week 3-4

#### Step 1: Install EDB Postgres Advanced Server

```bash
# On all PostgreSQL nodes (pg-dc1-1, pg-dc1-2, pg-dc1-3, pg-dc2-1, pg-dc2-2, pg-dc2-3)

# Add EDB repository
sudo dnf -y install https://dl.enterprisedb.com/default/release/get/16/rpm

# Install EDB Postgres Advanced Server
sudo dnf -y install edb-as16-server edb-as16-contrib

# Initialize database cluster
sudo /usr/edb/as16/bin/edb-as-16-setup initdb

# Start and enable service
sudo systemctl start edb-as-16
sudo systemctl enable edb-as-16
```

#### Step 2: Configure primary database (DC1)

**postgresql.conf (pg-dc1-1):**

```ini
listen_addresses = '*'
port = 5432
max_connections = 1500
shared_buffers = 8GB
effective_cache_size = 24GB
work_mem = 64MB
maintenance_work_mem = 2GB

# Replication Settings
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
wal_keep_size = 1GB
hot_standby = on
hot_standby_feedback = on
synchronous_standby_names = 'pg-dc1-2'  # Local sync standby
synchronous_commit = on

# Archive Settings
archive_mode = on
archive_command = 'barman-cloud-wal-archive --cloud-provider aws-s3 --endpoint-url https://s3.us-east-1.amazonaws.com s3://aap-wal-dc1 edb-cluster %p'
archive_timeout = 60

# Performance Tuning
checkpoint_timeout = 15min
checkpoint_completion_target = 0.9
random_page_cost = 1.1  # For SSD
effective_io_concurrency = 200
```

**pg_hba.conf additions (pg-dc1-1):**

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    replication     replicator      10.1.2.22/32            scram-sha-256  # pg-dc1-2
host    replication     replicator      10.1.2.23/32            scram-sha-256  # pg-dc1-3
host    replication     replicator      10.2.2.21/32            scram-sha-256  # pg-dc2-1 (cross-DC)

# AAP database access
host    awx                     aap     10.1.1.0/24             scram-sha-256
host    automationhub           aap     10.1.1.0/24             scram-sha-256
host    automationedacontroller aap     10.1.1.0/24             scram-sha-256
host    automationgateway       aap     10.1.1.0/24             scram-sha-256
```

#### Step 3: Initialize AAP databases

```sql
-- On pg-dc1-1
CREATE ROLE aap LOGIN PASSWORD 'SCRAM-SHA-256$...' ENCRYPTED;
CREATE ROLE replicator REPLICATION LOGIN PASSWORD 'SCRAM-SHA-256$...' ENCRYPTED;

CREATE DATABASE awx OWNER aap;
CREATE DATABASE automationhub OWNER aap;
CREATE DATABASE automationedacontroller OWNER aap;
CREATE DATABASE automationgateway OWNER aap;

-- automation_hub requires hstore extension
\c automationhub
CREATE EXTENSION IF NOT EXISTS hstore;
```

#### Step 4: Set up local standbys (DC1-2, DC1-3)

```bash
# On pg-dc1-2
sudo systemctl stop edb-as-16
sudo -u enterprisedb rm -rf /var/lib/edb/as16/data/*
sudo -u enterprisedb pg_basebackup -h pg-dc1-1 -U replicator \
  -D /var/lib/edb/as16/data -P -Xs -R --slot=pg_dc1_2_slot -C

# Start standby
sudo systemctl start edb-as-16

# Verify replication
psql -h pg-dc1-1 -U postgres -c "SELECT * FROM pg_stat_replication;"
```

Repeat for pg-dc1-3 with slot `pg_dc1_3_slot`.

#### Step 5: Set up cross-datacenter standby (DC2-1)

```bash
# On pg-dc2-1
sudo systemctl stop edb-as-16
sudo -u enterprisedb rm -rf /var/lib/edb/as16/data/*
sudo -u enterprisedb pg_basebackup -h pg-dc1-1 -U replicator \
  -D /var/lib/edb/as16/data -P -Xs -R --slot=pg_dc2_1_slot -C

# Start designated primary (currently in standby role)
sudo systemctl start edb-as-16

# Verify cross-DC replication
psql -h pg-dc1-1 -U postgres -c "SELECT application_name, state, sync_state FROM pg_stat_replication WHERE application_name='pg-dc2-1';"
```

Set up pg-dc2-2 and pg-dc2-3 as standbys of pg-dc2-1.

#### Step 6: Install and configure EDB Failover Manager (EFM)

```bash
# On all PostgreSQL nodes
sudo dnf -y install edb-efm47

# Configure EFM properties
sudo vi /etc/edb/efm-4.7/efm.properties
```

**/etc/edb/efm-4.7/efm.properties (pg-dc1-1):**

```ini
# Database Configuration
db.user=efm
db.password.encrypted=<encrypted_password>
db.port=5432
db.database=postgres

# Node Configuration
bind.address=10.1.2.21:7800
is.witness=false
db.service.owner=enterprisedb
db.service.name=edb-as-16
db.bin=/usr/edb/as16/bin

# Membership (all nodes in DC1 cluster)
nodes=10.1.2.21:7800 10.1.2.22:7800 10.1.2.23:7800

# Auto-failover Settings
auto.failover=true
auto.reconfigure=true
failover.timeout=60
node.timeout=60

# Virtual IP (for AAP connection)
virtual.ip=10.1.2.100
virtual.ip.interface=eth0
virtual.ip.prefix=24
virtual.ip.single=true

# Post-promotion Script (AAP integration)
script.post.promotion=/usr/edb/efm-4.7/bin/efm-orchestrated-failover.sh %h %s %a %v
enable.custom.scripts=true
script.timeout=600

# Notification
notification.level=WARNING
user.email=ops@example.com
```

Start EFM:

```bash
sudo systemctl start edb-efm-4.7
sudo systemctl enable edb-efm-4.7

# Verify cluster status
/usr/edb/efm-4.7/bin/efm cluster-status efm
```

#### Step 7: Configure WAL archiving to S3

```bash
# Install barman-cli on all PostgreSQL nodes
sudo dnf -y install barman-cli

# Configure S3 credentials
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
EOF

# Test WAL archiving
barman-cloud-wal-archive --cloud-provider aws-s3 \
  --endpoint-url https://s3.us-east-1.amazonaws.com \
  s3://aap-wal-dc1 edb-cluster /tmp/test.wal
```

---

### Phase 3: AAP Installation

**Operational Impact:** Medium -- installs AAP services, requires database connectivity

**Duration:** Week 5-6

#### Step 8: Download AAP containerized installer

```bash
# On a controller node in DC1
cd /opt
tar -xzf ansible-automation-platform-containerized-setup-2.6-1.tar.gz
cd ansible-automation-platform-containerized-setup-2.6-1
```

#### Step 9: Create unified inventory file

**/opt/aap/inventory:**

```ini
# Red Hat Ansible Automation Platform 2.6 - Container Enterprise Topology
# Multi-Datacenter Active/Passive Configuration

# Platform Gateway (4 VMs - 2 per DC with colocated Redis)
[automationgateway]
gateway1-dc1.example.com
gateway2-dc1.example.com
gateway1-dc2.example.com
gateway2-dc2.example.com

# Automation Controller (4 VMs - 2 per DC, dedicated)
[automationcontroller]
controller1-dc1.example.com
controller2-dc1.example.com
controller1-dc2.example.com
controller2-dc2.example.com

# Automation Hub (4 VMs - 2 per DC with colocated Redis)
[automationhub]
hub1-dc1.example.com
hub2-dc1.example.com
hub1-dc2.example.com
hub2-dc2.example.com

# Event-Driven Ansible (4 VMs - 2 per DC with colocated Redis)
[automationeda]
eda1-dc1.example.com
eda2-dc1.example.com
eda1-dc2.example.com
eda2-dc2.example.com

# Redis (colocated on gateway, hub, and EDA nodes)
[redis]
gateway1-dc1.example.com
gateway2-dc1.example.com
hub1-dc1.example.com
hub2-dc1.example.com
eda1-dc1.example.com
eda2-dc1.example.com
gateway1-dc2.example.com
gateway2-dc2.example.com
hub1-dc2.example.com
hub2-dc2.example.com
eda1-dc2.example.com
eda2-dc2.example.com

[all:vars]
# Common variables
postgresql_admin_username=postgres
postgresql_admin_password='<set your own>'

# Red Hat Registry Credentials
registry_username='<your RHN username>'
registry_password='<your RHN password>'

# Redis Configuration
redis_mode='standalone'

# Platform Gateway Configuration
gateway_admin_password='<set your own>'
gateway_pg_database='automationgateway'
gateway_pg_username='aap'
gateway_pg_password='<set your own>'
gateway_main_url='https://aap.example.com'

# Automation Controller Configuration
controller_admin_password='<set your own>'
controller_pg_database='awx'
controller_pg_username='aap'
controller_pg_password='<set your own>'

# Automation Hub Configuration
hub_admin_password='<set your own>'
hub_pg_database='automationhub'
hub_pg_username='aap'
hub_pg_password='<set your own>'

# Event-Driven Ansible Configuration
eda_admin_password='<set your own>'
eda_pg_database='automationedacontroller'
eda_pg_username='aap'
eda_pg_password='<set your own>'

# DC1-specific host variables (pointing to DC1 HAProxy)
[automationgateway:vars]
gateway1-dc1.example.com gateway_pg_host='10.1.1.20' gateway_pg_port='5432'
gateway2-dc1.example.com gateway_pg_host='10.1.1.20' gateway_pg_port='5432'

[automationcontroller:vars]
controller1-dc1.example.com controller_pg_host='10.1.1.20' controller_pg_port='5432'
controller2-dc1.example.com controller_pg_host='10.1.1.20' controller_pg_port='5432'

[automationhub:vars]
hub1-dc1.example.com hub_pg_host='10.1.1.20' hub_pg_port='5432'
hub2-dc1.example.com hub_pg_host='10.1.1.20' hub_pg_port='5432'

[automationeda:vars]
eda1-dc1.example.com eda_pg_host='10.1.1.20' eda_pg_port='5432'
eda2-dc1.example.com eda_pg_host='10.1.1.20' eda_pg_port='5432'

# DC2-specific host variables (pointing to DC2 HAProxy)
gateway1-dc2.example.com gateway_pg_host='10.2.1.20' gateway_pg_port='5432'
gateway2-dc2.example.com gateway_pg_host='10.2.1.20' gateway_pg_port='5432'
controller1-dc2.example.com controller_pg_host='10.2.1.20' controller_pg_port='5432'
controller2-dc2.example.com controller_pg_host='10.2.1.20' controller_pg_port='5432'
hub1-dc2.example.com hub_pg_host='10.2.1.20' hub_pg_port='5432'
hub2-dc2.example.com hub_pg_host='10.2.1.20' hub_pg_port='5432'
eda1-dc2.example.com eda_pg_host='10.2.1.20' eda_pg_port='5432'
eda2-dc2.example.com eda_pg_host='10.2.1.20' eda_pg_port='5432'
```

> **Critical:** DC2 nodes will be STOPPED after installation. All admin passwords and database credentials must match between DC1 and DC2 for seamless failover.

#### Step 10: Install AAP on DC1 (active)

```bash
cd /opt/ansible-automation-platform-containerized-setup-2.6-1

# Run installer
./setup.sh

# Verify installation
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Enable systemd services
systemctl enable --now automation-controller-web
systemctl enable --now automation-controller-task
systemctl enable --now automation-gateway
systemctl enable --now automation-hub
systemctl enable --now eda-activation-worker
systemctl enable --now redis
```

#### Step 11: Install AAP on DC2 (standby) and stop services

```bash
# On DC2 nodes
cd /opt/ansible-automation-platform-containerized-setup-2.6-1

# CRITICAL: Ensure SECRET_KEY matches DC1
# Copy /etc/tower/SECRET_KEY from DC1 to DC2 before install

# Run installer
./setup.sh

# IMMEDIATELY STOP all AAP containers (standby mode)
systemctl stop automation-controller-web automation-controller-task
systemctl stop automation-gateway automation-hub eda-activation-worker redis

# Disable auto-start
systemctl disable automation-controller-web automation-controller-task
systemctl disable automation-gateway automation-hub eda-activation-worker redis
```

#### Step 12: Configure HAProxy for database connection routing

**/etc/haproxy/haproxy.cfg (DC1 and DC2):**

```haproxy
global
    log /dev/log local0 info
    chroot /var/lib/haproxy
    stats socket /var/lib/haproxy/stats mode 600 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    maxconn 4000

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 10s
    timeout client  1h
    timeout server  1h
    timeout check   5s
    retries 3

# Backend - PostgreSQL VIP (EFM-managed)
backend postgresql_backend
    mode tcp
    balance roundrobin
    
    # External health check validates writable node
    option external-check
    external-check path "/usr/bin:/bin"
    external-check command /usr/local/bin/check-postgres-writable.sh
    
    # Single backend: EFM-managed VIP always points to PRIMARY
    server postgresql-vip 10.1.2.100:5432 check inter 5s rise 2 fall 3 maxconn 500

# Frontend - AAP Database Connections
frontend postgresql_frontend
    bind *:5432
    mode tcp
    default_backend postgresql_backend

# Stats interface
listen stats
    bind *:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
    stats auth admin:ChangeMeStats123!
```

**External health check script:**

```bash
#!/bin/bash
# /usr/local/bin/check-postgres-writable.sh

PGHOST="${1:-10.1.2.100}"
PGPORT="${2:-5432}"
PGUSER="haproxy_healthcheck"
PGDATABASE="postgres"
TIMEOUT=3

# Check 1: PostgreSQL is reachable
if ! timeout "${TIMEOUT}" pg_isready -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -q; then
    logger -t haproxy-healthcheck "PostgreSQL unreachable: ${PGHOST}:${PGPORT}"
    exit 1
fi

# Check 2: PostgreSQL is NOT in recovery (writable PRIMARY)
IS_RECOVERY=$(timeout "${TIMEOUT}" psql \
    -h "${PGHOST}" -p "${PGPORT}" -U "${PGUSER}" -d "${PGDATABASE}" \
    -t -c "SELECT pg_is_in_recovery();" 2>/dev/null | tr -d '[:space:]')

if [[ "${IS_RECOVERY}" == "f" ]]; then
    exit 0  # Writable PRIMARY
else
    logger -t haproxy-healthcheck "PostgreSQL is read-only: ${PGHOST}:${PGPORT}"
    exit 1  # Read-only STANDBY
fi
```

Create health check user:

```sql
-- On primary database
CREATE USER haproxy_healthcheck WITH PASSWORD 'HealthCheckPassword123!';
GRANT CONNECT ON DATABASE postgres TO haproxy_healthcheck;

-- Add to pg_hba.conf
# TYPE  DATABASE        USER                    ADDRESS         METHOD
host    postgres        haproxy_healthcheck     10.1.1.0/24     scram-sha-256
host    postgres        haproxy_healthcheck     10.2.1.0/24     scram-sha-256
```

Start HAProxy:

```bash
sudo systemctl enable --now haproxy
```

---

### Phase 4: Integration and Automation

**Operational Impact:** Medium -- failover automation configuration

**Duration:** Week 7-8

#### Step 13: Create EFM post-promotion script for AAP activation

**/usr/edb/efm-4.7/bin/efm-orchestrated-failover.sh:**

```bash
#!/bin/bash
# EFM Post-Promotion Script: Start AAP containers in failover datacenter

set -e

CLUSTER_NAME="$1"
NODE_TYPE="$2"
NODE_ADDRESS="$3"
VIP_ADDRESS="$4"

# Determine datacenter
if [[ "$NODE_ADDRESS" == *"dc2"* ]] || [[ "$NODE_ADDRESS" == "10.2"* ]]; then
    DATACENTER="DC2"
    GATEWAY_NODES=("gateway1-dc2" "gateway2-dc2")
    CONTROLLER_NODES=("controller1-dc2" "controller2-dc2")
    HUB_NODES=("hub1-dc2" "hub2-dc2")
    EDA_NODES=("eda1-dc2" "eda2-dc2")
else
    echo "ERROR: Failover to DC1 not expected"
    exit 1
fi

# Start AAP containers by component type
echo "Starting Platform Gateway nodes in $DATACENTER..."
for node in "${GATEWAY_NODES[@]}"; do
    ssh "$node" "systemctl start automation-gateway redis"
done

echo "Starting Automation Controller nodes in $DATACENTER..."
for node in "${CONTROLLER_NODES[@]}"; do
    ssh "$node" "systemctl start automation-controller-web automation-controller-task"
done

echo "Starting Automation Hub nodes in $DATACENTER..."
for node in "${HUB_NODES[@]}"; do
    ssh "$node" "systemctl start automation-hub redis"
done

echo "Starting Event-Driven Ansible nodes in $DATACENTER..."
for node in "${EDA_NODES[@]}"; do
    ssh "$node" "systemctl start eda-activation-worker redis"
done

# Wait for AAP API
MAX_WAIT=300
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if curl -k -s https://10.2.1.11/api/v2/ping/ | grep -q "200"; then
        echo "AAP is ready in $DATACENTER"
        break
    fi
    sleep 10
    ELAPSED=$((ELAPSED + 10))
done

# Send notifications
logger -t efm-failover "AAP activated in $DATACENTER"
```

Make executable and configure SSH keys:

```bash
chmod +x /usr/edb/efm-4.7/bin/efm-orchestrated-failover.sh

# Configure passwordless SSH from all PostgreSQL nodes to all AAP nodes
# (Required for post-promotion script to start services)
```

#### Step 14: Configure Global Load Balancer

Example Route53 configuration:

```json
{
  "HostedZoneId": "Z1234567890ABC",
  "ChangeBatch": {
    "Changes": [
      {
        "Action": "CREATE",
        "ResourceRecordSet": {
          "Name": "aap.example.com",
          "Type": "A",
          "SetIdentifier": "DC1-Primary",
          "Failover": "PRIMARY",
          "HealthCheckId": "health-check-dc1",
          "AliasTarget": {
            "HostedZoneId": "Z1234567890ABC",
            "DNSName": "aap-dc1.example.com",
            "EvaluateTargetHealth": true
          }
        }
      },
      {
        "Action": "CREATE",
        "ResourceRecordSet": {
          "Name": "aap.example.com",
          "Type": "A",
          "SetIdentifier": "DC2-Secondary",
          "Failover": "SECONDARY",
          "HealthCheckId": "health-check-dc2",
          "AliasTarget": {
            "HostedZoneId": "Z1234567890ABC",
            "DNSName": "aap-dc2.example.com",
            "EvaluateTargetHealth": true
          }
        }
      }
    ]
  }
}
```

Health check endpoint: `https://aap-dc1.example.com/api/v2/ping/`

#### Step 15: Set up monitoring and alerting

**Prometheus alert rules:**

```yaml
# /etc/prometheus/alert-rules.yml

groups:
  - name: aap_alerts
    interval: 30s
    rules:
      - alert: AAPAPIDown
        expr: probe_success{job="aap-api"} == 0
        for: 3m
        labels:
          severity: critical
        annotations:
          summary: "AAP API is down on {{ $labels.instance }}"

      - alert: PostgreSQLReplicationLagHigh
        expr: pg_replication_lag_seconds > 30
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High replication lag on {{ $labels.instance }}"

      - alert: PostgreSQLReplicationStopped
        expr: pg_replication_is_replica == 1 and pg_replication_lag_seconds == -1
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Replication stopped on {{ $labels.instance }}"
```

---

### Phase 5: Testing and Validation

**Operational Impact:** High during failover tests -- production traffic should be drained before testing

**Duration:** Week 9-10

#### Step 16: Test local database failover (within DC1)

```bash
# Simulate primary failure
ssh pg-dc1-1 "sudo systemctl stop edb-as-16"

# EFM should automatically promote pg-dc1-2
# Monitor with:
/usr/edb/efm-4.7/bin/efm cluster-status efm

# Verify VIP moved
ping 10.1.2.100

# Verify new primary
psql -h 10.1.2.100 -U postgres -c "SELECT pg_is_in_recovery();"
# Expected: f (false)
```

#### Step 17: Test cross-datacenter failover (DC1 → DC2)

```bash
# Stop AAP in DC1
for node in gateway1-dc1 gateway2-dc1; do
    ssh "$node" "systemctl stop automation-gateway redis"
done
for node in controller1-dc1 controller2-dc1; do
    ssh "$node" "systemctl stop automation-controller-web automation-controller-task"
done
for node in hub1-dc1 hub2-dc1; do
    ssh "$node" "systemctl stop automation-hub redis"
done
for node in eda1-dc1 eda2-dc1; do
    ssh "$node" "systemctl stop eda-activation-worker redis"
done

# Promote DC2 database to primary
ssh pg-dc2-1 "sudo -u enterprisedb /usr/edb/as16/bin/pg_ctl promote -D /var/lib/edb/as16/data"

# Post-promotion script should start AAP in DC2
# Monitor logs:
tail -f /var/log/messages | grep efm-failover

# Verify AAP API in DC2
curl -k https://10.2.1.11/api/v2/ping/
```

#### Step 18: Test failback procedure (DC2 → DC1)

See [Validation](#validation) section for complete failback procedure.

#### Step 19: Measure RTO/RPO

Document actual failover times:

- Database promotion: ~15 seconds
- AAP startup: ~3 minutes
- GLB detection: ~30 seconds
- **Total RTO:** ~240 seconds (under 5-minute target)

---

### Phase 6: Production Cutover

**Operational Impact:** High -- production migration

**Duration:** Week 11-12

#### Step 20: Final configuration review

- Security hardening (TLS, firewall rules, credential rotation)
- RBAC configuration in automation controller
- Backup validation (test restore from Barman)
- Documentation review (runbooks, escalation procedures)

#### Step 21: Production data migration

- Export automation controller data from existing deployment
- Import to new multi-DC deployment
- Validate projects, inventories, credentials, job templates

#### Step 22: User acceptance testing

- Execute critical job templates
- Verify workflow templates
- Test EDA rulebook activations
- Validate RBAC policies

#### Step 23: Go-live

- Update DNS to point to Global Load Balancer
- Monitor health checks and replication lag
- Execute daily health check runbook (see [Operational Runbook](#operational-runbook))

---

## Validation

### Per-Stage Validation Checklist

| Stage | What to Verify | Success Indicator |
|-------|---------------|-------------------|
| **Infrastructure** | All VMs provisioned and accessible | SSH connectivity from provisioning host |
| **Network** | Firewall rules configured | `nc -zv <ip> <port>` succeeds for all required ports |
| **PostgreSQL Primary** | Database service running | `systemctl status edb-as-16` shows active |
| **AAP Databases** | Four databases created | `psql -l` shows awx, automationhub, automationedacontroller, automationgateway |
| **Local Replication** | Standbys replicating from primary | `SELECT * FROM pg_stat_replication;` shows pg-dc1-2, pg-dc1-3 |
| **Cross-DC Replication** | DC2 replicating from DC1 | `SELECT * FROM pg_stat_replication;` shows pg-dc2-1 |
| **EFM Cluster** | Cluster status healthy | `/usr/edb/efm-4.7/bin/efm cluster-status efm` shows all nodes |
| **VIP** | Virtual IP assigned to primary | `ping 10.1.2.100` resolves to pg-dc1-1 |
| **AAP DC1** | Services running | `podman ps` shows all containers on all DC1 AAP nodes |
| **AAP DC2** | Services stopped | `podman ps` shows no containers on DC2 AAP nodes |
| **HAProxy** | Routing to PostgreSQL VIP | `psql -h 10.1.1.20 -U aap -d awx` connects successfully |
| **AAP API** | Controller API responding | `curl -k https://aap.example.com/api/v2/ping/` returns 200 |
| **Local Failover** | EFM promotes local standby | Stop pg-dc1-1; pg-dc1-2 becomes primary within 60s |
| **Cross-DC Failover** | EFM promotes DC2 and starts AAP | Promote pg-dc2-1; AAP starts in DC2 within 5 minutes |
| **GLB Routing** | Traffic redirects to DC2 | `curl https://aap.example.com` resolves to DC2 after failover |

### Health Check Commands

**Database health check:**

```bash
#!/bin/bash
# /usr/local/bin/check-postgres-health.sh

PG_HOST="${1:-localhost}"
PG_PORT="${2:-5432}"

if ! pg_isready -h "$PG_HOST" -p "$PG_PORT" -U postgres; then
    echo "CRITICAL: PostgreSQL not accepting connections"
    exit 2
fi

IS_REPLICA=$(psql -h "$PG_HOST" -p "$PG_PORT" -U postgres -t -c "SELECT pg_is_in_recovery();")
if [ "$IS_REPLICA" = " t" ]; then
    LAG=$(psql -h "$PG_HOST" -p "$PG_PORT" -U postgres -t -c \
        "SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()));")
    if (( $(echo "$LAG > 60" | bc -l) )); then
        echo "CRITICAL: Replication lag is ${LAG}s"
        exit 2
    fi
fi

echo "OK: PostgreSQL healthy"
exit 0
```

**AAP health check:**

```bash
#!/bin/bash
# /usr/local/bin/check-aap-health.sh

AAP_URL="${1:-https://localhost}"
HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 10 "$AAP_URL/api/v2/ping/")

if [ "$HTTP_CODE" = "200" ]; then
    echo "OK: AAP API responding"
    exit 0
else
    echo "CRITICAL: AAP API returned HTTP $HTTP_CODE"
    exit 2
fi
```

### Failback Procedure (DC2 → DC1)

After DC1 infrastructure is restored:

```bash
# 1. Rebuild DC1 as standby of DC2
ssh pg-dc1-1 "sudo systemctl stop edb-as-16"
ssh pg-dc1-1 "sudo -u enterprisedb rm -rf /var/lib/edb/as16/data/*"
ssh pg-dc1-1 "sudo -u enterprisedb pg_basebackup -h pg-dc2-1 -U replicator \
    -D /var/lib/edb/as16/data -P -Xs -R --slot=pg_dc1_1_slot"

# 2. Start DC1 as standby
ssh pg-dc1-1 "sudo systemctl start edb-as-16"

# 3. Verify replication DC2→DC1
ssh pg-dc2-1 "psql -U postgres -c \"SELECT * FROM pg_stat_replication;\""

# 4. Wait for minimal replication lag (< 5 seconds)

# 5. Stop AAP in DC2
for node in gateway1-dc2 gateway2-dc2; do
    ssh "$node" "systemctl stop automation-gateway redis"
done
for node in controller1-dc2 controller2-dc2; do
    ssh "$node" "systemctl stop automation-controller-web automation-controller-task"
done
for node in hub1-dc2 hub2-dc2; do
    ssh "$node" "systemctl stop automation-hub redis"
done
for node in eda1-dc2 eda2-dc2; do
    ssh "$node" "systemctl stop eda-activation-worker redis"
done

# 6. Promote DC1 back to primary
ssh pg-dc1-1 "sudo -u enterprisedb /usr/edb/as16/bin/pg_ctl promote -D /var/lib/edb/as16/data"

# 7. Configure DC2 as standby again
ssh pg-dc2-1 "sudo systemctl stop edb-as-16"
ssh pg-dc2-1 "sudo -u enterprisedb rm -rf /var/lib/edb/as16/data/*"
ssh pg-dc2-1 "sudo -u enterprisedb pg_basebackup -h pg-dc1-1 -U replicator \
    -D /var/lib/edb/as16/data -P -Xs -R --slot=pg_dc2_1_slot"
ssh pg-dc2-1 "sudo systemctl start edb-as-16"

# 8. Start AAP in DC1
for node in gateway1-dc1 gateway2-dc1; do
    ssh "$node" "systemctl start automation-gateway redis"
done
for node in controller1-dc1 controller2-dc1; do
    ssh "$node" "systemctl start automation-controller-web automation-controller-task"
done
for node in hub1-dc1 hub2-dc1; do
    ssh "$node" "systemctl start automation-hub redis"
done
for node in eda1-dc1 eda2-dc1; do
    ssh "$node" "systemctl start eda-activation-worker redis"
done

# 9. Update Global Load Balancer back to DC1

# 10. Verify normal operations
curl -k https://aap.example.com/api/v2/ping/
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Replication lag increasing | WAN bandwidth saturated or high latency | Verify network connectivity; check `pg_stat_replication` for `write_lag`, `flush_lag`, `replay_lag` |
| EFM failover does not trigger | `auto.failover=false` or insufficient quorum | Verify EFM properties; ensure majority of nodes can communicate |
| AAP containers fail to start in DC2 | Database not ready or incorrect connection string | Verify PostgreSQL VIP is accessible from AAP nodes; check HAProxy backend status |
| HAProxy health check fails | Database in recovery mode (read-only) | Verify `pg_is_in_recovery()` returns `f`; check EFM VIP assignment |
| Cross-DC replication stopped | Replication slot removed or network partition | Recreate replication slot; verify VPN/Direct Connect connectivity |
| Post-promotion script timeout | SSH keys not configured or AAP startup slow | Verify passwordless SSH from PostgreSQL nodes to AAP nodes; increase `script.timeout` in EFM properties |

---

## Operational Runbook

### Daily Health Check

```bash
#!/bin/bash
# /usr/local/bin/daily-health-check.sh

echo "Checking AAP DC1..."
/usr/local/bin/check-aap-health.sh https://10.1.1.11

echo "Checking PostgreSQL DC1..."
/usr/local/bin/check-postgres-health.sh 10.1.2.100

echo "Checking PostgreSQL DC2 replication..."
ssh pg-dc1-1 "psql -U postgres -c \"SELECT application_name, state, sync_state, write_lag, flush_lag, replay_lag FROM pg_stat_replication WHERE application_name='pg-dc2-1';\""

echo "Checking EFM cluster status..."
/usr/edb/efm-4.7/bin/efm cluster-status efm
```

### Emergency Failover to DC2

```bash
# /usr/local/bin/manual-failover-dc2.sh

# Stop AAP in DC1
for node in gateway1-dc1 gateway2-dc1 controller1-dc1 controller2-dc1 hub1-dc1 hub2-dc1 eda1-dc1 eda2-dc1; do
    ssh "$node" "systemctl stop automation-*"
done

# Promote DC2 database
ssh pg-dc2-1 "sudo -u enterprisedb /usr/edb/as16/bin/pg_ctl promote -D /var/lib/edb/as16/data"

# Start AAP in DC2
for node in gateway1-dc2 gateway2-dc2 controller1-dc2 controller2-dc2 hub1-dc2 hub2-dc2 eda1-dc2 eda2-dc2; do
    ssh "$node" "systemctl start automation-*"
done

# Update Global Load Balancer
echo "Update GLB to route to DC2"
```

### Rolling Restart of AAP Component

```bash
# Example: restart controller1-dc1 for patching

# 1. Drain jobs
# (Manual via AAP UI or API)

# 2. Stop services
ssh controller1-dc1 "systemctl stop automation-controller-web automation-controller-task"

# 3. Perform maintenance
ssh controller1-dc1 "dnf update -y && reboot"

# 4. Start services
ssh controller1-dc1 "systemctl start automation-controller-web automation-controller-task"

# 5. Verify health
curl -k https://controller1-dc1/api/v2/ping/
```

---

## Maturity Path

| Maturity | Description | What to Build |
|----------|-------------|---------------|
| **Crawl** | Single-datacenter AAP with local HA via EFM; manual failover procedures documented and tested quarterly | Deploy AAP 2.6 Container Enterprise Topology with 3-node PostgreSQL cluster and EFM in one datacenter; document manual backup/restore procedures; test restore from Barman quarterly |
| **Walk** | Multi-datacenter with manual failover procedures; cross-DC replication active; DR drills every 6 months | Deploy this full architecture; disable `auto.failover` in EFM; execute manual failover procedure during scheduled maintenance windows; measure and document actual RTO/RPO |
| **Run** | Automated failover with < 5-minute RTO; EFM orchestrates database promotion and AAP activation; continuous monitoring with alerting on replication lag and cluster health | Enable `auto.failover=true` in EFM; deploy Prometheus/Grafana with alert rules; integrate post-promotion script with ITSM/Slack for automated incident creation; quarterly DR drills with business stakeholders observing |

---

## Related Guides

- [Red Hat Ansible Automation Platform Documentation](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/)
- [AAP 2.6 Containerized Installation Guide](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/containerized_installation)
- [AAP 2.6 Container Enterprise Topology](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/tested_deployment_models/container-topologies#cont-b-env-a)
- [EDB Postgres Advanced Server Documentation](https://www.enterprisedb.com/docs/epas/latest/)
- [EDB Failover Manager Documentation](https://www.enterprisedb.com/docs/efm/latest/)
- [Barman Documentation](https://www.enterprisedb.com/docs/supported-open-source/barman/)

---

## Summary

By implementing this multi-datacenter Active-Passive DR architecture, you have deployed mission-critical Ansible Automation Platform with guaranteed automation continuity:

- **RTO < 5 minutes** -- automated failover via EFM eliminates manual intervention during datacenter failures
- **RPO < 5 seconds** -- streaming replication protects against data loss for mission-critical automation workflows
- **Production-validated topology** -- based on Red Hat's Container Enterprise Topology extended to multi-datacenter configuration
- **Complete operational runbook** -- daily health checks, emergency failover procedures, and failback validation commands
- **Automated orchestration** -- EFM post-promotion script coordinates database promotion and AAP service activation without operator intervention

**Infrastructure scale:**

- **26 VMs total** (13 per datacenter)
- **68 vCPU, 272GB RAM per datacenter**
- **Conforms to Red Hat AAP 2.6 Container Enterprise Topology** for single-datacenter design
- **Extends with multi-datacenter Active-Passive DR** for mission-critical use cases

This architecture ensures automation availability for workflows that cannot tolerate downtime -- network orchestration, security compliance enforcement, multi-cloud deployments, and automated incident response.

---

**Document Version:** 1.0  
**Last Review:** 2026-04-20  
**Based On:** AAP Containerized Multi-Datacenter DR Architecture v2.0 (2026-03-31)

{% endraw %}
