# 10. Crear un Security Group para el NLB: permite tráfico TCP entrante desde cualquier ip
resource "aws_security_group" "nlb_sg" {
  vpc_id = aws_vpc.main.id
  name   = "nlb-sg"

  # Permitir tráfico TCP por el puerto 80 desde cualquier ip
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir tráfico desde cualquier dirección IP
  }

  # Permitir todo el tráfico de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Permitir cualquier tráfico de salida
  }

  tags = {
    Name = "nlb-security-group"
  }
}

# 11. Crear un Security Group para las tareas de ECS: permite tráfico entrante solo desde el NLB para mayor seguridad.
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id
  name   = "ecs-sg"

  # Permitir tráfico desde el NLB por el puerto 80
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nlb_sg.id] # Solo permite tráfico proveniente del NLB
  }

  # Permitir todo el tráfico de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Permitir cualquier tráfico de salida
  }

  tags = {
    Name = "ecs-security-group"
  }
}