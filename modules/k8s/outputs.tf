output "namespace" {
  description = "Namespace Kubernetes de l'application"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "service_name" {
  description = "Nom du Service Kubernetes"
  value       = kubernetes_service.app.metadata[0].name
}

output "deployment_name" {
  description = "Nom du Deployment Kubernetes"
  value       = kubernetes_deployment.app.metadata[0].name
}