resource "aws_cloudwatch_log_group" "jenkins-log" {
  name = "jenkins-log"

  tags = {
    Environment = "production"
    Application = "jenkins"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "jenkins-cluster"
}

resource "aws_ecs_task_definition" "jenkins-td" {
  family                   = "jenkins-td"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]


  volume {
    name = "service-storage"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.jenkins_data.id
      root_directory          = "/jenkins_home"
    }
  }
  container_definitions = <<TASK_DEFINITION
[
    {
        "cpu": 256,
        "environment": [
            {"name": "JENKINS_HOME", "value": "/var/jenkins_home"}
        ],
        "essential": true,
        "image": "jenkins/jenkins",
        "memory": 1024,
        "name": "jenkins",
        "portMappings": [
            {
                "containerPort": 8080,
                "hostPort": 8080
            }
        ],
        "mountPoints": [
                {
                    "readOnly": null,
                    "containerPath": "/var/jenkins_home",
                    "sourceVolume": "service-storage"
                }
        ],
        "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "jenkins-log",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "jenkins-log"
                }
            }
    }
]
TASK_DEFINITION
}

resource "aws_security_group" "task-sg" {
  name        = "jenkins-task-sg"
  description = "Allow jenkins inbound traffic to task"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins-task-sg"
  }
}

resource "aws_ecs_service" "jenkins-service" {
  name            = "jenkins-service"
  platform_version = "1.4.0"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.jenkins-td.arn
  desired_count   = 1
  # iam_role        = aws_iam_role.foo.arn
  # depends_on      = [aws_iam_role_policy.foo]
  launch_type                        = "FARGATE"
  network_configuration {
    security_groups  = [aws_security_group.task-sg.id]
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
  }
}


