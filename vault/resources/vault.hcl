backend "s3" {
  bucket = ""
  access_key = ""
  secret_key = ""
  region = "eu-west-1"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}

max_lease_ttl = "8640h"
default_lease_ttl = "2160h"
