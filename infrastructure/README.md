# Infrastructure - Terraform

## Overview

This directory provisions **3 Ubuntu 22.04 EC2 instances** on AWS for the Ansible practice tasks:

| Instance | Purpose |
|----------|---------|
| control | Ansible control node |
| node1 | Managed node |
| node2 | Managed node |

## Resources Created

- 1 VPC with DNS support
- 1 Public Subnet
- 1 Internet Gateway + Route Table
- 1 Security Group (SSH + port 9103)
- 3 EC2 instances (t2.micro by default)

## Security Group Rules

| Direction | Port | Protocol | Source | Purpose |
|-----------|------|----------|--------|---------|
| Ingress | 22 | TCP | Configurable CIDR | External SSH access |
| Ingress | 22 | TCP | VPC CIDR | SSH between nodes |
| Ingress | 9103 | TCP | VPC CIDR | Collectd Prometheus metrics |
| Egress | All | All | 0.0.0.0/0 | Outbound traffic |

## Prerequisites

1. AWS CLI configured with valid credentials
2. An existing SSH key pair in AWS (or create one)
3. Terraform >= 1.0 installed

## Usage

```bash
# Initialize Terraform
terraform init

# Review execution plan
terraform plan -var="key_name=your-key-name"

# Apply infrastructure
terraform apply -var="key_name=your-key-name"

# Destroy when done
terraform destroy -var="key_name=your-key-name"
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `instance_type` | EC2 instance type | `t2.micro` |
| `key_name` | SSH key pair name | (required) |
| `ami` | Ubuntu 22.04 AMI ID | `ami-0c7217cdde317cfec` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `subnet_cidr` | Subnet CIDR block | `10.0.1.0/24` |
| `allowed_ssh_cidr` | CIDR allowed for SSH | `0.0.0.0/0` |

## Outputs

After `terraform apply`, the following outputs are available:

- `instance_public_ips` - Public IPs mapped by instance name
- `instance_private_ips` - Private IPs mapped by instance name
- `ssh_connection_commands` - Ready-to-use SSH commands
- `inventory_snippet` - Ansible inventory YAML to copy into your hosts.yml

## SSH Configuration

After provisioning, you can generate an SSH config:

```bash
# Add to ~/.ssh/config
Host ansible-control
    HostName <control-public-ip>
    User ubuntu
    IdentityFile ~/.ssh/your-key-name.pem

Host ansible-node1
    HostName <node1-public-ip>
    User ubuntu
    IdentityFile ~/.ssh/your-key-name.pem

Host ansible-node2
    HostName <node2-public-ip>
    User ubuntu
    IdentityFile ~/.ssh/your-key-name.pem
```

Replace IPs with the values from `terraform output instance_public_ips`.
