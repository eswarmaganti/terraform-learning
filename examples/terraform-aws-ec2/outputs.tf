output "ubuntu-ami-name" {
  value = data.aws_ami.ami.name
}
output "ubuntu-ami-id" {
  value = data.aws_ami.ami.id
}

output "ec2_servers_count_public_ips" {
  value  = [for server in  aws_instance.ec2_servers_count: server.public_ip ]
}

output "ec2_servers_foreach_public_ips" {
  value  = [for server in  aws_instance.ec2_servers_foreach: server.public_ip ]
}