output "vpc_id" {
  value = aws_vpc.historynet.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.web_a.id, aws_subnet.web_b.id,
    aws_subnet.was_a.id, aws_subnet.was_b.id,
    aws_subnet.db_a.id, aws_subnet.db_b.id
  ]
}
output "bastion_eip" {
  description = "Public IP of the Bastion Host"
  value       = aws_eip.bastion_ip.public_ip
}
