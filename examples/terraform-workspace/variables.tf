variable "instance_type" {
  description = "The instance type of the EC2 VM"
  type        = string
  default     = "t3.micro"
}

variable "name_tag" {
  type        = string
  description = "Name of the EC2 instance"
  default     = "EC2"
}
