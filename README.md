# Practical Task: Ansible Configuration Management

## Project Architecture

This repository contains a complete infrastructure automation and configuration management solution using **Terraform** for provisioning and **Ansible** for configuration.

```
practical_task_ansible/
├── infrastructure/              # Terraform - AWS EC2 provisioning
│   ├── main.tf                 # VPC, Security Groups, EC2 instances
│   ├── variables.tf            # Configurable parameters
│   ├── outputs.tf              # Instance IPs and connection info
│   └── README.md
├── task1-adhoc-and-playbooks/  # Task 1: Ad-hoc commands & basic playbooks
│   ├── inventory/
│   │   └── hosts.yml
│   ├── playbooks/
│   │   └── network_interfaces.yml
│   └── README.md
├── task2-common-role/          # Task 2: Common role (packages + SELinux)
│   ├── roles/
│   │   └── common/
│   ├── playbooks/
│   ├── inventory/
│   └── README.md
├── task3-collectd-role/        # Task 3: Collectd role (install/remove)
│   ├── roles/
│   │   └── collectd/
│   ├── playbooks/
│   ├── inventory/
│   └── README.md
└── README.md                   # This file
```

## Infrastructure

The infrastructure consists of **3 Ubuntu 22.04 EC2 instances** on AWS:

| Node | Role |
|------|------|
| control | Ansible control node |
| node1 | Managed node |
| node2 | Managed node |

All nodes are within the same VPC and security group, allowing SSH access between them and external access on port 9103 (Prometheus metrics).

## Task Descriptions

### Task 1 - Ad-hoc Commands and Playbooks (10 pts)

- Install Ansible on the control node
- Configure inventory with managed nodes
- Execute ad-hoc commands (ping, uname, uptime, package installation)
- Gather facts (hostname, distribution)
- Write a playbook to display network interfaces

### Task 2 - Common Role (30 pts)

- Create a role `common` that installs a configurable list of packages
- Handle SELinux disabling with conditional reboot
- Demonstrate idempotent execution

### Task 3 - Collectd Role (60 pts)

- Create a role `collectd` with install/remove logic controlled by a variable
- Use Jinja2 templates for collectd configuration
- Expose Prometheus metrics on port 9103
- Handle service lifecycle (start, stop, enable, disable)
- Clean removal of packages and configuration files

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.15
- AWS account with configured credentials
- SSH key pair for EC2 access

## Quick Start

```bash
# 1. Provision infrastructure
cd infrastructure
terraform init
terraform apply

# 2. Run Task 1 - Ad-hoc commands
cd ../task1-adhoc-and-playbooks
ansible managed_nodes -m ansible.builtin.ping -i inventory/hosts.yml

# 3. Run Task 2 - Common role
cd ../task2-common-role
ansible-playbook playbooks/common_playbook.yml -i inventory/hosts.yml

# 4. Run Task 3 - Collectd role
cd ../task3-collectd-role
ansible-playbook playbooks/install_collectd_playbook.yml -i inventory/hosts.yml
```

## Commit Conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

| Type | Usage |
|------|-------|
| `feat(taskN)` | New feature for a specific task |
| `fix(taskN)` | Bug fix in a specific task |
| `infra` | Infrastructure changes (Terraform) |
| `docs` | Documentation updates |
| `chore` | Maintenance, scaffolding |
| `refactor` | Code restructuring |

## Author

University practical assignment - Infrastructure Automation course
