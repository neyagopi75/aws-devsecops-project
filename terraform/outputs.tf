
output "jenkins_public_ip" {
  description = "Public IP address of Jenkins EC2"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "Jenkins web interface"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}
