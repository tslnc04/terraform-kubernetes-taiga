terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.0.0"
    }
  }
}

resource "kubernetes_namespace_v1" "taiga_ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map_v1" "taiga_config" {
  metadata {
    name      = "taiga-environment"
    namespace = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  }

  data = {
    POSTGRES_USER        = "taiga"
    POSTGRES_DB          = "taiga"
    EMAIL_BACKEND        = "django.core.mail.backends.console.EmailBackend"
    RABBITMQ_USER        = "taiga"
    RABBITMQ_VHOST       = "taiga"
    ENABLE_TELEMETRY     = "true"
    MAX_AGE              = "360"
    TAIGA_SITES_SCHEME   = "https"
    TAIGA_SITES_DOMAIN   = var.http_route.hostnames[0]
    TAIGA_URL            = "https://${var.http_route.hostnames[0]}"
    TAIGA_WEBSOCKETS_URL = "wss://${var.http_route.hostnames[0]}"
    TAIGA_SUBPATH        = ""
  }
}

resource "kubernetes_manifest" "taiga_secret" {
  manifest = {
    apiVersion = "onepassword.com/v1"
    kind       = "OnePasswordItem"

    metadata = {
      name      = "taiga-environment"
      namespace = kubernetes_namespace_v1.taiga_ns.metadata[0].name
    }

    spec = {
      itemPath = var.secret_path
    }
  }
}

module "taiga_db" {
  source      = "./modules/taiga-db"
  namespace   = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  secret      = kubernetes_manifest.taiga_secret.manifest.metadata.name
  config_map  = kubernetes_config_map_v1.taiga_config.metadata[0].name
  volume_path = var.db_path
  pv_prefix   = var.pv_prefix
  pv_node     = var.pv_node
}

module "taiga_back_volumes" {
  source      = "./modules/taiga-back-volumes"
  namespace   = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  pv_prefix   = var.pv_prefix
  pv_node     = var.pv_node
  static_path = var.static_path
  media_path  = var.media_path
}

module "taiga_back" {
  source          = "./modules/taiga-back"
  name            = "back"
  namespace       = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  secret          = kubernetes_manifest.taiga_secret.manifest.metadata.name
  config_map      = kubernetes_config_map_v1.taiga_config.metadata[0].name
  events_rabbitmq = module.taiga_events_rabbitmq.domain
  async_rabbitmq  = module.taiga_async_rabbitmq.domain
  postgres        = module.taiga_db.domain
  static_volume   = module.taiga_back_volumes.static_volume
  media_volume    = module.taiga_back_volumes.media_volume
}

module "taiga_async" {
  source          = "./modules/taiga-back"
  name            = "async"
  namespace       = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  secret          = kubernetes_manifest.taiga_secret.manifest.metadata.name
  config_map      = kubernetes_config_map_v1.taiga_config.metadata[0].name
  events_rabbitmq = module.taiga_events_rabbitmq.domain
  async_rabbitmq  = module.taiga_async_rabbitmq.domain
  postgres        = module.taiga_db.domain
  static_volume   = module.taiga_back_volumes.static_volume
  media_volume    = module.taiga_back_volumes.media_volume
  async           = true
}

module "taiga_async_rabbitmq" {
  source      = "./modules/taiga-rabbitmq"
  name        = "async"
  namespace   = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  secret      = kubernetes_manifest.taiga_secret.manifest.metadata.name
  config_map  = kubernetes_config_map_v1.taiga_config.metadata[0].name
  volume_path = var.async_rabbitmq_path
  pv_prefix   = var.pv_prefix
  pv_node     = var.pv_node
}

module "taiga_front" {
  source     = "./modules/taiga-front"
  namespace  = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  config_map = kubernetes_config_map_v1.taiga_config.metadata[0].name
}

module "taiga_events" {
  source     = "./modules/taiga-events"
  namespace  = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  secret     = kubernetes_manifest.taiga_secret.manifest.metadata.name
  config_map = kubernetes_config_map_v1.taiga_config.metadata[0].name

  depends_on = [module.taiga_events_rabbitmq]
}

module "taiga_events_rabbitmq" {
  source      = "./modules/taiga-rabbitmq"
  name        = "events"
  namespace   = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  secret      = kubernetes_manifest.taiga_secret.manifest.metadata.name
  config_map  = kubernetes_config_map_v1.taiga_config.metadata[0].name
  volume_path = var.events_rabbitmq_path
  pv_prefix   = var.pv_prefix
  pv_node     = var.pv_node
}

module "taiga_protected" {
  source     = "./modules/taiga-protected"
  namespace  = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  secret     = kubernetes_manifest.taiga_secret.manifest.metadata.name
  config_map = kubernetes_config_map_v1.taiga_config.metadata[0].name
}

module "taiga_gateway" {
  source           = "./modules/taiga-gateway"
  namespace        = kubernetes_namespace_v1.taiga_ns.metadata[0].name
  front_domain     = module.taiga_front.domain
  back_domain      = module.taiga_back.domain
  events_domain    = module.taiga_events.domain
  protected_domain = module.taiga_protected.domain
  static_volume    = module.taiga_back_volumes.static_volume
  media_volume     = module.taiga_back_volumes.media_volume
  http_route       = var.http_route
}
