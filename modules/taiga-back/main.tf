terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.0.0"
    }
  }
}

locals {
  app_name = "taiga-${var.name}"
  app_port = 8000
}

resource "kubernetes_deployment_v1" "taiga_back_deployment" {
  metadata {
    name      = local.app_name
    namespace = var.namespace

    labels = {
      app = local.app_name
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = local.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.app_name
        }
      }

      spec {
        container {
          name    = local.app_name
          image   = "docker.io/taigaio/taiga-back:latest"
          command = var.async ? ["/taiga-back/docker/async_entrypoint.sh"] : null

          env {
            name  = "POSTGRES_HOST"
            value = var.postgres
          }

          env {
            name  = "TAIGA_EVENTS_RABBITMQ_HOST"
            value = var.events_rabbitmq
          }

          env {
            name  = "TAIGA_ASYNC_RABBITMQ_HOST"
            value = var.async_rabbitmq
          }

          env_from {
            config_map_ref {
              name = var.config_map
            }
          }

          env_from {
            secret_ref {
              name = var.secret
            }
          }

          volume_mount {
            name       = var.static_volume
            mount_path = "/taiga-back/static"
          }

          volume_mount {
            name       = var.media_volume
            mount_path = "/taiga-back/media"
          }

          port {
            container_port = local.app_port
          }
        }

        volume {
          name = var.static_volume

          persistent_volume_claim {
            claim_name = var.static_volume
          }
        }

        volume {
          name = var.media_volume

          persistent_volume_claim {
            claim_name = var.media_volume
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "taiga_back_service" {
  metadata {
    name      = local.app_name
    namespace = var.namespace

    labels = {
      app = local.app_name
    }
  }

  spec {
    selector = {
      app = local.app_name
    }

    port {
      port        = local.app_port
      target_port = local.app_port
    }
  }

  depends_on = [kubernetes_deployment_v1.taiga_back_deployment]
}
