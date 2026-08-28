variable "app_replicas" {
  description = "Nombre de réplicas initial du Deployment"
  type        = number
  default     = 2
}

variable "app_image" {
  description = "Image du conteneur à déployer"
  type        = string
  default     = "nginx:1.27-alpine"
}