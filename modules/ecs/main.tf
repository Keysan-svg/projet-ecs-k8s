# Dépôt ECR pour stocker l'image de l'application
resource "aws_ecr_repository" "app" {
  name                 = "projet-ecs-k8s-app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Cluster ECS
resource "aws_ecs_cluster" "main" {
  name = "projet-ecs-k8s-cluster"
}

# VPC et subnets par défaut (fournis par AWS Academy)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group restreint : autorise uniquement le port 80 en entrée
resource "aws_security_group" "app" {
  name        = "projet-ecs-k8s-sg"
  description = "Allows only HTTP inbound traffic to the application"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from outside"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound access for pulling ECR image"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "projet-ecs-k8s-sg"
  }
}

# Task definition : décrit le conteneur à exécuter
resource "aws_ecs_task_definition" "app" {
  family                   = "projet-ecs-k8s-task"
  requires_compatibilities = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "256"
  memory                    = "512"
  execution_role_arn        = var.labrole_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:${var.app_image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])
}

# Groupe de logs CloudWatch pour observer l'application
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/projet-ecs-k8s"
  retention_in_days = 3
}

# Service ECS : maintient le nombre de tâches désiré (scaling + auto-réparation)
resource "aws_ecs_service" "app" {
  name            = "projet-ecs-k8s-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = true
  }
}