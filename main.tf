provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "devops-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "devops_vpc"
  cidr                 = var.devops_vpc_cidr_block
  azs                  = ["us-east-1a", "us-east-1b"]
  private_subnets      = var.devops_private_subnets
  public_subnets       = var.devops_public_subnets
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  tags = {
    Terraform   = "true"
    Environment = "devops-ci"
  }
}


module "stag-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "staging_vpc"
  cidr                 = var.stag_vpc_cidr_block
  azs                  = ["us-east-1a", "us-east-1b"]
  private_subnets      = var.stag_private_subnets
  public_subnets       = var.stag_public_subnets
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}

module "prod-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "prod_vpc"
  cidr                 = var.prod_vpc_cidr_block
  azs                  = ["us-east-1a", "us-east-1b"]
  private_subnets      = var.prod_private_subnets
  public_subnets       = var.prod_public_subnets
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}


resource "aws_vpc_peering_connection" "prod-peering" {
  #peer_owner_id = var.peer_owner_id
  peer_vpc_id = module.prod-vpc.vpc_id
  vpc_id      = module.devops-vpc.vpc_id
  auto_accept = true
}

resource "aws_vpc_peering_connection" "stag-peering" {
  #peer_owner_id = var.peer_owner_id
  peer_vpc_id = module.prod-vpc.vpc_id
  vpc_id      = module.devops-vpc.vpc_id
  auto_accept = true
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
  content         = tls_private_key.example.private_key_pem
  filename        = "/root/pemkey_client.pem"
  file_permission = "0400"
}


