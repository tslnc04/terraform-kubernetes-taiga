terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.0.0"
    }
  }
}

locals {
  app_name           = "taiga-gateway"
  gateway_config_map = "taiga-gateway-config"
  app_port           = 80
}

resource "kubernetes_deployment_v1" "taiga_gateway_deployment" {
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
          image = "docker.io/nginx:1-alpine"

          volume_mount {
            name       = "taiga-gateway-conf"
            mount_path = "/etc/nginx/conf.d/default.conf"
            sub_path   = "default.conf"
            read_only  = true
          }

          volume_mount {
            name       = var.static_volume
            mount_path = "/taiga/static"
          }

          volume_mount {
            name       = var.media_volume
            mount_path = "/taiga/media"
          }

          port {
            container_port = local.app_port
          }
        }

        volume {
          name = "taiga-gateway-conf"

          config_map {
            name = local.gateway_config_map
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

  depends_on = [kubernetes_config_map_v1.taiga_gateway_config]
}

resource "kubernetes_service_v1" "taiga_gateway_service" {
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

  depends_on = [kubernetes_deployment_v1.taiga_gateway_deployment]
}

resource "kubernetes_manifest" "taiga_gateway_route" {
  count = var.http_route == null ? 0 : 1

  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      name      = "taiga"
      namespace = var.namespace
    }

    spec = {
      hostnames = var.http_route.hostnames

      parentRefs = [{
        name        = var.http_route.parent_gateway.name
        namespace   = var.http_route.parent_gateway.namespace
        sectionName = var.http_route.parent_gateway.section_name
      }]

      rules = [{
        backendRefs = [{
          name = local.app_name
          port = local.app_port
        }]

        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }
        }]
      }]
    }
  }

  depends_on = [kubernetes_service_v1.taiga_gateway_service]
}
