output "domain" {
  description = "domain for this front instance's service"
  value       = "${local.app_name}.${var.namespace}.svc.cluster.local:${local.app_port}"
}