# Task 1 - Ansible Installation and Ad-hoc Commands (10 pts)

## Objective

Install Ansible on the control node, configure an inventory, run ad-hoc commands, gather facts, and execute a basic playbook.

## Prerequisites

- Infrastructure provisioned with Terraform (see `../infrastructure/`)
- SSH access to all nodes from the control node
- Ansible installed on the control node

## Step 1: Install Ansible on the Control Node

```bash
# Connect to control node
ssh -i ~/.ssh/ansible-key.pem ubuntu@<control-public-ip>

# Install Ansible
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Verify installation
ansible --version
```

## Step 2: Configure Inventory

The inventory file is located at `inventory/hosts.yml`. Update the `ansible_host` values with the actual public IPs from Terraform output:

```bash
cd ../infrastructure
terraform output instance_public_ips
```

Edit `inventory/hosts.yml` with the correct IPs.

## Step 3: Ad-hoc Commands

### Ping all managed nodes

```bash
ansible managed_nodes -m ansible.builtin.ping -i inventory/hosts.yml
```

Expected output:
```
node1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
node2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Get system information

```bash
ansible managed_nodes -m ansible.builtin.command -a "uname -a" -i inventory/hosts.yml
```

Expected output:
```
node1 | CHANGED | rc=0 >>
Linux ip-10-0-1-x 5.15.0-xxx-generic #xxx-Ubuntu SMP ... x86_64 GNU/Linux
```

### Check uptime

```bash
ansible managed_nodes -m ansible.builtin.command -a "uptime" -i inventory/hosts.yml
```

Expected output:
```
node1 | CHANGED | rc=0 >>
 12:00:00 up 1 min,  1 user,  load average: 0.00, 0.00, 0.00
```

### Install htop package

```bash
ansible managed_nodes -m ansible.builtin.apt -a "name=htop state=present" --become -i inventory/hosts.yml
```

Expected output:
```
node1 | CHANGED => {
    "changed": true,
    ...
}
node2 | CHANGED => {
    "changed": true,
    ...
}
```

## Step 4: Gather Facts

### Get hostname

```bash
ansible managed_nodes -m ansible.builtin.setup -a "filter=ansible_hostname" -i inventory/hosts.yml
```

Expected output:
```
node1 | SUCCESS => {
    "ansible_facts": {
        "ansible_hostname": "ip-10-0-1-x"
    }
}
```

### Get distribution info

```bash
ansible managed_nodes -m ansible.builtin.setup -a "filter=ansible_distribution" -i inventory/hosts.yml
```

Expected output:
```
node1 | SUCCESS => {
    "ansible_facts": {
        "ansible_distribution": "Ubuntu"
    }
}
```

## Step 5: Run Network Interfaces Playbook

```bash
ansible-playbook playbooks/network_interfaces.yml -i inventory/hosts.yml
```

Expected output:
```
PLAY [Display network interfaces on managed nodes] ****************************

TASK [Gathering Facts] ********************************************************
ok: [node1]
ok: [node2]

TASK [Print all network interfaces] *******************************************
ok: [node1] => {
    "msg": ["lo", "eth0"]
}
ok: [node2] => {
    "msg": ["lo", "eth0"]
}

TASK [Print detailed info for each interface] *********************************
ok: [node1] => (item=eth0) => {
    "msg": "Interface: eth0, IPv4: 10.0.1.x"
}
ok: [node2] => (item=eth0) => {
    "msg": "Interface: eth0, IPv4: 10.0.1.x"
}

PLAY RECAP ********************************************************************
node1                      : ok=3    changed=0    ...
node2                      : ok=3    changed=0    ...
```

## File Structure

```
task1-adhoc-and-playbooks/
├── inventory/
│   └── hosts.yml          # Inventory with managed_nodes group
├── playbooks/
│   └── network_interfaces.yml  # Playbook to display network interfaces
└── README.md              # This file
```

## Summary

| Step | Command/Action | Points |
|------|---------------|--------|
| Ansible installation | `apt install ansible` | Part of setup |
| Ping | `ansible.builtin.ping` | Ad-hoc |
| System info | `ansible.builtin.command` with uname | Ad-hoc |
| Uptime | `ansible.builtin.command` with uptime | Ad-hoc |
| Package install | `ansible.builtin.apt` with become | Ad-hoc |
| Facts - hostname | `ansible.builtin.setup` filter | Facts |
| Facts - distribution | `ansible.builtin.setup` filter | Facts |
| Network interfaces | Playbook execution | Playbook |
