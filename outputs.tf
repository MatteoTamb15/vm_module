output "name" {
  value       = google_compute_instance.vm.name
  description = "Nome della VM."
}

output "internal_ip" {
  value       = google_compute_instance.vm.network_interface[0].network_ip
  description = "IP interno della VM."
}

output "external_ip" {
  value       = try(google_compute_instance.vm.network_interface[0].access_config[0].nat_ip, "N/A")
  description = "IP esterno della VM."
}


output "attached_disk_id" {
  value       = try(google_compute_disk.attached_disk[0].id, null)
  description = "ID del disco attached (if created)"
}

output "attached_disk_self_link" {
  value       = try(google_compute_disk.attached_disk[0].self_link, null)
  description = "Self link del disco attached (if created)"
}

output "disk_labels" {
  value       = try(google_compute_disk.attached_disk[0].labels, {})
  description = "Labels del disco attached (if created)"
}

output "vm_labels" {
  value       = google_compute_instance.vm.labels
  description = "Labels assegnate alla VM"
}

output "vm_tags" {
  value       = google_compute_instance.vm.tags
  description = "Tags assegnati alla VM"
}

