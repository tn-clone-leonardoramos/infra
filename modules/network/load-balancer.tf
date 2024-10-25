# 12. Crear un Load Balancer (NLB): estará en las subnets privadas para gestionar el tráfico HTTP hacia las tareas de ECS.
# se crea un network load balancer para que la Api gateway pueda dirigir el trafico a este a traves de una VPC link
# (VPC link solo funciona para NLB y no para ALB)
resource "aws_lb" "ecs_lb" {
  name               = "ecs-load-balancer"
  internal           = true # Debe ser privado (API gateway se encaraga del trafico publico)
  load_balancer_type = "network"
  security_groups    = [aws_security_group.nlb_sg.id] # Asociar el Security Group del NLB
  subnets            = aws_subnet.private[*].id       # Colocar el NLB en las subnets privadas

  tags = {
    Name = "ecs-lb"
  }
}

# 13. Crear un listener para el Load Balancer: escucha en el puerto 80 para tráfico HTTP.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn # Redirigir el tráfico al grupo objetivo de ECS
  }
}

# 14. Crear un Target Group para ECS: donde se enviará el tráfico desde el NLB hacia las tareas de ECS en subnets privadas.
resource "aws_lb_target_group" "ecs_tg" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # ECS Fargate usa IPs para direccionar el tráfico

  # Configurar una verificación de salud para las tareas de ECS
  health_check {
    path                = "/healthcheck"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Name = "ecs-tg"
  }
}
