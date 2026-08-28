# Namespace dédié pour isoler l'application
resource "kubernetes_namespace" "app" {
  metadata {
    name = "projet-app"
  }
}

# ConfigMap : configuration de l'application (page HTML personnalisée)
resource "kubernetes_config_map" "app" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    "index.html" = <<-EOT
      <!DOCTYPE html>
      <html>
      <head><title>Projet Kubernetes</title></head>
      <body style="font-family: sans-serif; text-align: center; margin-top: 100px;">
        <h1>Application deployee via Kubernetes (Minikube)</h1>
        <p>IPSSI - Mastere Cybersecurite et Cloud Computing</p>
      </body>
      </html>
    EOT
  }
}

# Deployment : plusieurs réplicas avec limites de ressources
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "app-deployment"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "projet-app"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "projet-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "projet-app"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = var.app_image

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.app.metadata[0].name
          }
        }
      }
    }
  }
}

# Service : expose le Deployment à l'intérieur du cluster
resource "kubernetes_service" "app" {
  metadata {
    name      = "app-service"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "projet-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# Ingress : expose le Service vers l'extérieur du cluster
resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "app-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# HPA : ajuste automatiquement le nombre de réplicas selon la charge CPU
resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  metadata {
    name      = "app-hpa"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    min_replicas = 2
    max_replicas = 6

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}

# NetworkPolicy : restreint le trafic entrant au namespace uniquement (garde-fou sécurité)
resource "kubernetes_network_policy" "app" {
  metadata {
    name      = "app-network-policy"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = "projet-app"
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = kubernetes_namespace.app.metadata[0].name
          }
        }
      }

      ports {
        port     = 80
        protocol = "TCP"
      }
    }

    ingress {
      from {
        namespace_selector {}
      }

      ports {
        port     = 80
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}