terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.0.0"
    }
  }
}

locals {
  static_volume_name = "${var.pv_prefix}-back-static"
  media_volume_name  = "${var.pv_prefix}-back-media"
}

resource "kubernetes_persistent_volume_v1" "taiga_back_static_pv" {
  metadata {
    name = local.static_volume_name
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
        path = var.static_path
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
      name      = local.static_volume_name
      namespace = var.namespace
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "taiga_back_static_pvc" {
  metadata {
    name      = local.static_volume_name
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    storage_class_name = var.storage_class
    volume_name        = local.static_volume_name
  }

  depends_on = [kubernetes_persistent_volume_v1.taiga_back_static_pv]
}

resource "kubernetes_persistent_volume_v1" "taiga_back_media_pv" {
  metadata {
    name = local.media_volume_name
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
        path = var.media_path
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
      name      = local.media_volume_name
      namespace = var.namespace
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "taiga_back_media_pvc" {
  metadata {
    name      = local.media_volume_name
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    storage_class_name = var.storage_class
    volume_name        = local.media_volume_name
  }

  depends_on = [kubernetes_persistent_volume_v1.taiga_back_media_pv]
}
