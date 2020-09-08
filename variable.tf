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
variable "devops_vpc_cidr_block" {}
variable "devops_public_subnets" {}
variable "devops_private_subnets" {}
variable "enable_nat_gateway" {}
variable "single_nat_gateway" {}
variable "azs" {}


variable "stag_vpc_cidr_block" {}
variable "stag_public_subnets" {}
variable "stag_private_subnets" {}

variable "prod_vpc_cidr_block" {}
variable "prod_public_subnets" {}
variable "prod_private_subnets" {}