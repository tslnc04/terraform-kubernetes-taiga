output "domain" {
  description = "domain for this db instance's service"
  value       = "${local.app_name}.${var.namespace}.svc.cluster.local"
}
