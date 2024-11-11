output "section_name" {
  description = "name of the section in the gateway that the app attaches to"
  value       = module.taiga_gateway.section_name
}

output "hostname" {
  description = "hostname that the app is exposed at"
  value       = module.taiga_gateway.hostname
}
