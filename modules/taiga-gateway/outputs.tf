output "domain" {
  description = "domain for this gateway instance's service"
  value       = "${local.app_name}.${var.namespace}.svc.cluster.local:${local.app_port}"
}

output "section_name" {
  description = "name of the section in the gateway that the app attaches to"
  value       = var.http_route == null ? null : var.http_route.parent_gateway.section_name
}

output "hostname" {
  description = "hostname that the app is exposed at"
  value       = var.http_route == null ? null : var.http_route.hostnames[0]
}
