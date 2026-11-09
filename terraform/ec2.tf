
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_security_group" "jenkins" {
  name        = "jenkins-devsecops-sg"
  description = "Restricted access for Jenkins"

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["27.61.55.49/32"]
  }

  ingress {
    description = "Jenkins UI from my IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["27.61.55.49/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-devsecops-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = "t3.small"
  key_name               = "jenkins-devsecops-key"
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name    = "jenkins-server"
    Project = "AWS-DevSecOps"
  }
}
