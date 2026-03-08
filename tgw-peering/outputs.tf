output "amazon_linux_ami_id_ip" {
  value = aws_instance.ec2_a.private_ip
}

output "amazon_linux_ami_id_b_ip" {
  value = aws_instance.ec2_b.private_ip
}
