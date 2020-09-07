region = "us-east-1"

vpc_name = "devops_vpc"
vpc_cidr_block = "10.1.0.0/16"
public_subnets = ["10.1.100.0/24","10.1.101.0/24"]
private_subnets = ["10.1.1.0/24","10.1.2.0/24"]
enable_nat_gateway = true
single_nat_gateway = true
azs = ["us-east-1a","us-east-1b"]