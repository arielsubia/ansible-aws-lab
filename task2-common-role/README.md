# Task 2 - Common Role with Packages and SELinux (30 pts)

## Objective

Create an Ansible role `common` that:
1. Installs a configurable list of packages (does nothing if the list is empty)
2. Disables SELinux with a conditional reboot (only if SELinux was active)
3. Runs idempotently (second run produces 0 changes)

## Role Structure

```
roles/common/
├── defaults/
│   └── main.yml          # common_packages: [] (empty by default)
├── handlers/
│   └── main.yml          # Reboot handler for SELinux changes
├── meta/
│   └── main.yml          # Role metadata
└── tasks/
    ├── main.yml           # Includes install_packages.yml and selinux.yml
    ├── install_packages.yml  # Package installation logic
    └── selinux.yml        # SELinux disable logic
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `common_packages` | `[]` | List of packages to install. Nothing is installed if empty. |

## Usage

### Run the playbook

```bash
ansible-playbook playbooks/common_playbook.yml -i inventory/hosts.yml
```

### First run (expected output)

```
PLAY [Apply common configuration to managed nodes] ****************************

TASK [Gathering Facts] ********************************************************
ok: [node1]
ok: [node2]

TASK [common : Install common packages] ***************************************
changed: [node1]
changed: [node2]

TASK [common : Check if SELinux config file exists] ***************************
ok: [node1]
ok: [node2]

TASK [common : Skip SELinux tasks (not applicable on this system)] ************
ok: [node1] => {
    "msg": "SELinux is not installed or already disabled - skipping"
}
ok: [node2]

PLAY RECAP ********************************************************************
node1                      : ok=4    changed=1    ...
node2                      : ok=4    changed=1    ...
```

### Second run (idempotent - 0 changed)

```
PLAY RECAP ********************************************************************
node1                      : ok=4    changed=0    ...
node2                      : ok=4    changed=0    ...
```

## Package List

The playbook installs the following packages:

| Package | Purpose |
|---------|---------|
| curl | HTTP client |
| lsof | List open files |
| mc | Midnight Commander file manager |
| nano | Text editor |
| tar | Archive utility |
| unzip | ZIP extraction |
| vim | Advanced text editor |
| zip | ZIP compression |

## SELinux Behavior

| Scenario | Action |
|----------|--------|
| SELinux not installed (Ubuntu default) | Skip with informational message |
| SELinux active (Enforcing/Permissive) | Disable + trigger reboot |
| SELinux already disabled | No changes |

## Verifying Package Installation

```bash
# Check packages on managed nodes
ansible managed_nodes -m ansible.builtin.command -a "dpkg -l curl lsof mc nano tar unzip vim zip" -i inventory/hosts.yml
```

## Testing Idempotency

Run the playbook twice and verify the second run shows `changed=0`:

```bash
# First run
ansible-playbook playbooks/common_playbook.yml -i inventory/hosts.yml

# Second run (should show 0 changed)
ansible-playbook playbooks/common_playbook.yml -i inventory/hosts.yml
```
