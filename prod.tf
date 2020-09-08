resource "aws_s3_bucket" "b1" {
  bucket = "alb-log-bucket-prod-sampleapp"
  acl    = "log-delivery-write"
  tags = {
    Name        = "alb-logs"
    Environment = "prod"
  }
}

resource "aws_security_group" "prod-alb-sg" {
  name        = "prod-alb-sg"
  vpc_id      = module.prod-vpc.vpc_id
  tags = {
    Name = "prod-alb-sg"
  }
}

resource "aws_security_group" "prod-instance-sg" {
  name        = "prod-instance-sg"
  vpc_id      = module.prod-vpc.vpc_id
  tags = {
    Name = "prod-instance-sg"
  }
}
resource "aws_security_group_rule" "prod-alb-rule_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.prod-alb-sg.id
}
resource "aws_security_group_rule" "prod-alb-rule" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.prod-instance-sg.id
  security_group_id = aws_security_group.prod-alb-sg.id
}

resource "aws_security_group_rule" "prod-instance-rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.prod-alb-sg.id
  security_group_id = aws_security_group.prod-instance-sg.id
}

module "prod-alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  name = "prod-alb"
  load_balancer_type = "application"
  vpc_id             = module.prod-vpc.vpc_id
  subnets            = module.prod-vpc.public_subnets
  security_groups    = [aws_security_group.prod-alb-sg.id]
  access_logs = {
    bucket = "alb-log-bucket-prod-sampleapp"
  }
  target_groups = [
    {
      name_prefix      = "prod-"
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
    Environment = "prod"
  }
}

module "prod-ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  name           = "prod-ec2"
  instance_count = 1
  ami                    = "ami-0c94855ba95c71c99"
  instance_type          = "t3.micro"
  key_name               = "pemkey1"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.prod-instance-sg.id]
  subnet_id              = module.prod-vpc.private_subnets[0]

  tags = {
    Terraform = "true"
    Environment = "prod"
  }
}


# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.test.arn
#   target_id        = aws_instance.test.id
#   port             = 80
# }