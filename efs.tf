resource "aws_efs_file_system" "jenkins_data" {
  creation_token = "jenkins-efs"
  tags = {
    Name = "jenkins-efs"
  }
}

resource "aws_security_group" "jenkins_data_allow_nfs_access" {
  name        = "jenkins-efs-allow-nfs"
  description = "Allow NFS inbound traffic to EFS"
  vpc_id      = module.devops-vpc.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins-efs-allow-nfs"
  }
}

resource "aws_security_group_rule" "jenkins_data_allow_nfs_access_rule" {
  security_group_id        = aws_security_group.jenkins_data_allow_nfs_access.id
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.task-sg.id
}

resource "aws_efs_mount_target" "jenkins_data_mount_targets" {
  count           = 2
  file_system_id  = aws_efs_file_system.jenkins_data.id
  subnet_id       = element(module.devops-vpc.private_subnets, count.index)
  security_groups = [aws_security_group.jenkins_data_allow_nfs_access.id]
}
