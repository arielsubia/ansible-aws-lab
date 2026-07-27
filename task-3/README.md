# Task 3 - Collectd Role with Install/Remove Logic

## Objective

Create an Ansible role `collectd` that:
1. Installs collectd with a Prometheus write plugin (exposes metrics on port 9103)
2. Uses a Jinja2 template for dynamic configuration
3. Supports complete removal via a variable toggle (`collectd_state`)
4. Handles service lifecycle properly
5. Runs idempotently in both install and remove modes

## Role Structure

```
roles/collectd/
├── defaults/
│   └── main.yml              # Default variables (state, port, plugins)
├── handlers/
│   └── main.yml              # Restart collectd handler
├── meta/
│   └── main.yml              # Role metadata
├── tasks/
│   ├── main.yml              # Conditional include based on collectd_state
│   ├── install_collectd.yml  # Install packages, deploy config, start service
│   └── remove_collectd.yml   # Stop service, remove packages and configs
└── templates/
    └── prometheus.conf.j2    # Jinja2 template for collectd configuration
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `collectd_state` | `install` | Set to `install` or `remove` |
| `collectd_prometheus_port` | `9103` | Port for Prometheus metrics endpoint |
| `collectd_plugins` | `[df, processes, protocols, swap, tcpconns, uptime, users, vmem]` | List of collectd plugins to enable |

## Usage

### Install collectd

```bash
ansible-playbook playbooks/install_collectd_playbook.yml -i inventory/hosts.yml
```

### Remove collectd

```bash
ansible-playbook playbooks/remove_collectd_playbook.yml -i inventory/hosts.yml
```

### Override variables at runtime

```bash
# Change port
ansible-playbook playbooks/install_collectd_playbook.yml -i inventory/hosts.yml \
  -e "collectd_prometheus_port=9104"

# Remove with extra vars
ansible-playbook playbooks/install_collectd_playbook.yml -i inventory/hosts.yml \
  -e "collectd_state=remove"
```

## Jinja2 Template

The `prometheus.conf.j2` template generates the collectd configuration:

```jinja2
# Load the write_prometheus plugin
LoadPlugin write_prometheus

# Load configured plugins
{% for plugin in collectd_plugins %}
LoadPlugin {{ plugin }}
{% endfor %}

# Configure write_prometheus plugin
<Plugin write_prometheus>
  Port "{{ collectd_prometheus_port }}"
</Plugin>
```

## Verification

### After install

```bash
# Check service status
ansible managed_nodes -m ansible.builtin.command -a "systemctl status collectd" \
  -i inventory/hosts.yml --become

# Verify metrics endpoint
ansible managed_nodes -m ansible.builtin.uri -a "url=http://localhost:9103/metrics return_content=yes" \
  -i inventory/hosts.yml

# Or with curl
ansible managed_nodes -m ansible.builtin.command -a "curl -s http://localhost:9103/metrics" \
  -i inventory/hosts.yml
```

Expected: Prometheus-formatted metrics output with collectd data.

### After remove

```bash
# Verify service is gone
ansible managed_nodes -m ansible.builtin.command -a "systemctl status collectd" \
  -i inventory/hosts.yml --become
# Expected: non-zero return code (service not found)

# Verify packages removed
ansible managed_nodes -m ansible.builtin.command -a "dpkg -l collectd" \
  -i inventory/hosts.yml
# Expected: error (package not installed)

# Verify config removed
ansible managed_nodes -m ansible.builtin.stat -a "path=/etc/collectd" \
  -i inventory/hosts.yml
# Expected: stat.exists = false
```

## Idempotency Testing

```bash
# Install twice - second run should show 0 changed
ansible-playbook playbooks/install_collectd_playbook.yml -i inventory/hosts.yml
ansible-playbook playbooks/install_collectd_playbook.yml -i inventory/hosts.yml

# Remove twice - second run should show 0 changed
ansible-playbook playbooks/remove_collectd_playbook.yml -i inventory/hosts.yml
ansible-playbook playbooks/remove_collectd_playbook.yml -i inventory/hosts.yml
```

## Flow Diagram

```
collectd_state == "install"         collectd_state == "remove"
        │                                     │
        ▼                                     ▼
 Install packages              Stop & disable service
        │                                     │
        ▼                                     ▼
 Deploy Jinja2 template         Remove packages (purge)
        │                                     │
        ▼                                     ▼
 Enable & start service         Remove config & data dirs
        │
        ▼
 Notify restart if config changed
```
