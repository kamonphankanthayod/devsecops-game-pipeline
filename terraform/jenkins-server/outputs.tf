output "jenkins_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.ec2.public_ip}:8080"
}