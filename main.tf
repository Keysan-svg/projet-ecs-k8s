terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

module "ecs" {
  source        = "./modules/ecs"
  aws_region    = var.aws_region
  app_image_tag = var.app_image_tag
  labrole_arn   = var.labrole_arn
}

module "k8s" {
  source       = "./modules/k8s"
  app_replicas = 2
  app_image    = "nginx:1.27-alpine"
}