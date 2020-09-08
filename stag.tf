resource "aws_s3_bucket" "b2" {
  bucket = "alb-log-bucket-stag-sampleapp"
  acl    = "log-delivery-write"
  tags = {
    Name        = "alb-logs"
    Environment = "stag"
  }
}

resource "aws_security_group" "stag-alb-sg" {
  name        = "stag-alb-sg"
  vpc_id      = module.stag-vpc.vpc_id
  tags = {
    Name = "stag-alb-sg"
  }
}

resource "aws_security_group" "stag-instance-sg" {
  name        = "stag-instance-sg"
  vpc_id      = module.stag-vpc.vpc_id
  tags = {
    Name = "stag-instance-sg"
  }
}
resource "aws_security_group_rule" "stag-alb-rule_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.stag-alb-sg.id
}
resource "aws_security_group_rule" "stag-alb-rule" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.stag-instance-sg.id
  security_group_id = aws_security_group.stag-alb-sg.id
}

resource "aws_security_group_rule" "stag-instance-rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.stag-alb-sg.id
  security_group_id = aws_security_group.stag-instance-sg.id
}

module "stag-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  name = "stag-alb"
  load_balancer_type = "application"
  vpc_id             = module.stag-vpc.vpc_id
  subnets            = module.stag-vpc.public_subnets
  security_groups    = [aws_security_group.stag-alb-sg.id]
  access_logs = {
    bucket = "alb-log-bucket-stag-sampleapp"
  }
  target_groups = [
    {
      name_prefix      = "stag-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  tags = {
    Environment = "stag"
  }
}

# module "stag-ec2" {
#       source                      = "git::https://github.com/clouddrove/terraform-aws-ec2.git?ref=tags/0.12.7"
#       name                        = "ec2-instance"
#       environment                 = "stag"
#       instance_count              = 1
#       ami                         = "ami-0c94855ba95c71c99"
#       instance_type               = "t3.small"
#       vpc_security_group_ids_list = [aws_security_group.stag-instance-sg.id]
#       subnet_ids                  = tolist(module.stag-vpc.private_subnets)
#       instance_tags               = { "snapshot" = true }
# }