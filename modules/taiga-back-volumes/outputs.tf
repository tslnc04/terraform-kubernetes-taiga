output "static_volume" {
  description = "name of the static PVC"
  value       = local.static_volume_name
}

output "media_volume" {
  description = "name of the media PVC"
  value       = local.media_volume_name
}
