output "domain" {
  description = "domain for this RabbitMQ instance's service"
  value       = "${local.app_name}.${var.namespace}.svc.cluster.local"
}
