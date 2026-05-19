variable "mongodb_creds" {
  type = map(string)
  default = {
    "MONGO_INITDB_ROOT_USERNAME" = "admin"
    "MONGO_INITDB_ROOT_PASSWORD" = "admin@123"
  }
}
