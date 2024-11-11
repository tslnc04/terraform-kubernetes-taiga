locals {
  app_name = "taiga-protected"
  app_port = 8003
}

resource "kubernetes_deployment_v1" "taiga_protected_deployment" {
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
          image = "docker.io/taigaio/taiga-protected:latest"

          env {
            name = "MAX_AGE"

            value_from {
              config_map_key_ref {
                key  = "MAX_AGE"
                name = var.config_map
              }
            }
          }

          env {
            name = "SECRET_KEY"

            value_from {
              secret_key_ref {
                key  = "TAIGA_SECRET_KEY"
                name = var.secret
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

resource "kubernetes_service_v1" "taiga_protected_service" {
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

  depends_on = [kubernetes_deployment_v1.taiga_protected_deployment]
}
