output "s3_bucket_arn" {
  value = aws_s3_bucket.s3_backend.arn
}
output "dynamo_db_table" {
  value = aws_dynamodb_table.db_table.name
}
output "availability_zones" {
  value = data.aws_availability_zones.azs.names
}
output "ec2_instances" {
  value = [for ec2 in aws_instance.ec2_instances : ec2.public_ip]
}
