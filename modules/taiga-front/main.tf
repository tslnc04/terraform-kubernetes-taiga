locals {
  app_name = "taiga-front"
  app_port = 80
}

resource "kubernetes_deployment_v1" "taiga_front_deployment" {
  metadata {
    name      = local.app_name
    namespace = var.namespace

    labels = {
      app = local.app_name
    }
  }

  spec {
    replicas = 1

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
          name  = local.app_name
          image = "docker.io/taigaio/taiga-front:latest"

          env {
            name = "TAIGA_URL"

            value_from {
              config_map_key_ref {
                key  = "TAIGA_URL"
                name = var.config_map
              }
            }
          }

          env {
            name = "TAIGA_WEBSOCKETS_URL"

            value_from {
              config_map_key_ref {
                key  = "TAIGA_WEBSOCKETS_URL"
                name = var.config_map
              }
            }
          }

          env {
            name = "TAIGA_SUBPATH"

            value_from {
              config_map_key_ref {
                key  = "TAIGA_SUBPATH"
                name = var.config_map
              }
            }
          }

          port {
            container_port = local.app_port
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "taiga_front_service" {
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

  depends_on = [kubernetes_deployment_v1.taiga_front_deployment]
}
