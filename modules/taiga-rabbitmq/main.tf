terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.0.0"
    }
  }
}

locals {
  volume_name = "${var.pv_prefix}-${var.name}-rabbitmq"
  app_name    = "taiga-${var.name}-rabbitmq"
  app_port    = 5672
}

resource "kubernetes_persistent_volume_v1" "taiga_rabbitmq_pv" {
  metadata {
    name = local.volume_name
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = var.storage_class

    persistent_volume_source {
      local {
        path = var.volume_path
      }
    }

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = [var.pv_node]
          }
        }
      }
    }

    claim_ref {
      name      = local.volume_name
      namespace = var.namespace
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "taiga_rabbitmq_pvc" {
  metadata {
    name      = local.volume_name
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOncePod"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    storage_class_name = var.storage_class
    volume_name        = local.volume_name
  }

  depends_on = [kubernetes_persistent_volume_v1.taiga_rabbitmq_pv]
}

resource "kubernetes_deployment_v1" "taiga_rabbitmq_deployment" {
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
          name  = local.app_name
          image = "docker.io/rabbitmq:3.8-management-alpine"

          env {
            name = "RABBITMQ_DEFAULT_USER"
            value_from {
              config_map_key_ref {
                key  = "RABBITMQ_USER"
                name = var.config_map
              }
            }
          }

          env {
            name = "RABBITMQ_DEFAULT_VHOST"
            value_from {
              config_map_key_ref {
                key  = "RABBITMQ_VHOST"
                name = var.config_map
              }
            }
          }

          env {
            name = "RABBITMQ_DEFAULT_PASS"

            value_from {
              secret_key_ref {
                key  = "RABBITMQ_PASS"
                name = var.secret
              }
            }
          }

          env {
            name = "RABBITMQ_ERLANG_COOKIE"

            value_from {
              secret_key_ref {
                key  = "RABBITMQ_ERLANG_COOKIE"
                name = var.secret
              }
            }
          }

          volume_mount {
            name       = local.volume_name
            mount_path = "/var/lib/rabbitmq"
          }

          port {
            container_port = local.app_port
          }
        }

        volume {
          name = local.volume_name

          persistent_volume_claim {
            claim_name = local.volume_name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_persistent_volume_claim_v1.taiga_rabbitmq_pvc]
}

resource "kubernetes_service_v1" "taiga_rabbitmq_service" {
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

  depends_on = [kubernetes_deployment_v1.taiga_rabbitmq_deployment]
}
