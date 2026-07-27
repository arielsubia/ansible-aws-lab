output "instance_public_ips" {
  description = "Public IPs of all instances"
  value = {
    for idx, instance in aws_instance.nodes :
    var.instance_names[idx] => instance.public_ip
  }
}

output "instance_private_ips" {
  description = "Private IPs of all instances"
  value = {
    for idx, instance in aws_instance.nodes :
    var.instance_names[idx] => instance.private_ip
  }
}

output "ssh_connection_commands" {
  description = "SSH commands to connect to each instance"
  value = {
    for idx, instance in aws_instance.nodes :
    var.instance_names[idx] => "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${instance.public_ip}"
  }
}

output "inventory_snippet" {
  description = "Ansible inventory snippet for managed nodes"
  value = <<-EOT
    managed_nodes:
      hosts:
        node1:
          ansible_host: ${aws_instance.nodes[1].public_ip}
        node2:
          ansible_host: ${aws_instance.nodes[2].public_ip}
      vars:
        ansible_user: ubuntu
        ansible_ssh_private_key_file: ~/.ssh/${var.key_name}.pem
  EOT
}
