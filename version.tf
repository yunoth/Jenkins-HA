terraform {
  required_version = ">= 0.12.10, < 0.14.0"

  required_providers {
    aws   = "~> 3.5.0"
    http  = "~> 1.2.0"
    tls   = "~> 2.2.0"
    local = "~> 1.4.0"
  }
}