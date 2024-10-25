# create task definition
resource "aws_ecs_task_definition" "user_task_definition" {
  family                   = "tn_users_api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "tn_users_api"
      image     = "nginx:latest" # imagen placeholder para deploy inicial (luego el ci/cd se encargara de usar la correcta)
      essential = true
      environment = [
        {
          name  = "PORT"
          value = "80"
        },
        {
          name = "DYNAMODB_TABLE"
          value = var.dynamo_db_user_table_name
        }
      ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# create ecs service
resource "aws_ecs_service" "ecs_tn_service_users_api" {
  name            = "tn_service_users_api"
  cluster         = aws_ecs_cluster.ecs_tn.id
  task_definition = aws_ecs_task_definition.user_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE" # default is ECS, so we need to specify FARGATE

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.nlb_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.nlb_target_group_arn
    container_name   = "tn_users_api"
    container_port   = 80
  }
}
