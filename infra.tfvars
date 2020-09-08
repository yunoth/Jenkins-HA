region = "us-east-1"

vpc_name               = "devops_vpc"
devops_vpc_cidr_block  = "10.1.0.0/16"
devops_public_subnets  = ["10.1.100.0/24", "10.1.101.0/24"]
devops_private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
enable_nat_gateway     = true
single_nat_gateway     = true
azs                    = ["us-east-1a", "us-east-1b"]



### staging vars

stag_vpc_cidr_block  = "10.2.0.0/16"
stag_public_subnets  = ["10.2.100.0/24", "10.2.101.0/24"]
stag_private_subnets = ["10.2.1.0/24", "10.2.2.0/24"]



### prod vars 

prod_vpc_cidr_block  = "10.3.0.0/16"
prod_public_subnets  = ["10.3.100.0/24", "10.3.101.0/24"]
prod_private_subnets = ["10.3.1.0/24", "10.3.2.0/24"]