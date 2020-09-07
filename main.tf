provider "aws" {
 access_key = var.access_key
 secret_key = var.secret_key
 region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "devops_vpc"
  cidr = var.vpc_cidr_block
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  enable_dns_hostnames = true
  enable_nat_gateway = true 
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

data "http" "myip" {
  url = "http://ifconfig.me"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "pemkey1"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "local_file" "public_key_openssh" {
  content  = tls_private_key.example.private_key_pem
  filename = "/root/pemkey_client.pem"
  file_permission = "0400"
}
