# secret manager
resource "aws_secretsmanager_secret" "secret" {
  name = "mongodb-creds"
}

resource "aws_secretsmanager_secret_version" "secret_data" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(var.mongodb_creds)
}
