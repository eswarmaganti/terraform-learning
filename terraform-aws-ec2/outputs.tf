output "ubuntu-ami-name" {
  value = data.aws_ami.ami.name
}
output "ubuntu-ami-id" {
  value = data.aws_ami.ami.id
}

output "ec2_servers_public_ips" {
  value  = [for server in  aws_instance.ec2_servers: server.public_ip ]
}