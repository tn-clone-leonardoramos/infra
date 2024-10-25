output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "nlb_security_group_id" {
  value = aws_security_group.nlb_sg.id
}

output "nlb_target_group_arn" {
  value = aws_lb_target_group.ecs_tg.arn
}

output "nlb_dns" {
  value = aws_lb.ecs_lb.dns_name
}

output "nlb_arn" {
  value = aws_lb.ecs_lb.arn
}
