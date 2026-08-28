variable "aws_region" {
  description = "Région AWS"
  type        = string
}

variable "app_image_tag" {
  description = "Tag de l'image Docker (jamais latest)"
  type        = string
}

variable "labrole_arn" {
  description = "ARN du rôle LabRole imposé par AWS Academy"
  type        = string
}