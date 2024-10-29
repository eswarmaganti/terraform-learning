variable "bucket_name" {
  type        = string
  description = "The s3 bucket name for remote backend"
  default     = "eswarmaganti-terraform-remote-state"
}

variable "dynamodb_table_name" {
  type        = string
  description = "The table name for dynamo db"
  default     = "terraform-state-lock"
}



variable "ec2_names" {
  type        = list(string)
  description = "the names of ec2 servers"
  default     = ["My-Test-EC2-01", "My-Test-EC2-02"]
}
