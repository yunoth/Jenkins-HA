variable "access_key" {
  type = "string"
  description = "AWS access_key id"
}

variable "secret_key" {
  type = "string"
  description = "AWS secret_key id"
}

variable "region" {
  type = "string"
  description = "AWS region"
  default = "us-east-1"
}

variable "vpc_name" {}
variable "vpc_cidr_block" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "enable_nat_gateway" {}
variable "single_nat_gateway" {}
variable "azs" {}