output "ecr_repository_url" {
  description = "URL du dépôt ECR (pour pousser l'image nginx)"
  value       = module.ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Nom du service ECS"
  value       = module.ecs.ecs_service_name
}

output "k8s_namespace" {
  description = "Namespace Kubernetes de l'application"
  value       = module.k8s.namespace
}

output "k8s_service_name" {
  description = "Nom du Service Kubernetes"
  value       = module.k8s.service_name
}

output "k8s_deployment_name" {
  description = "Nom du Deployment Kubernetes"
  value       = module.k8s.deployment_name
}