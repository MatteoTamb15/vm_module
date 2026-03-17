# Ottiene l'immagine più recente per la famiglia specificata solo se image non fornita
data "google_compute_image" "vm_image" {
  project = var.os_type == "windows" ? var.image_project_windows : var.image_project_linux
  family  = var.os_type == "windows" ? var.image_family_windows : var.image_family_linux
}

resource "google_compute_instance" "vm" {
  project      = var.project
  zone         = var.zone
  name         = var.name
  machine_type = var.machine_type
  tags         = var.tags
  labels       = var.labels

  boot_disk {
    initialize_params {
    image = coalesce(var.image, data.google_compute_image.vm_image.self_link)
      size  = var.boot_disk.initialize_params.size
      type  = var.boot_disk.initialize_params.type
    }
  }

  network_interface {
    network = var.network_interface.network
    access_config {}
  }

  dynamic "service_account" {
    for_each = length(var.service_account.scopes) > 0 ? [1] : []
    content {
      scopes = var.service_account.scopes
    }
  }

  
metadata_startup_script = <<-EOT

#!/bin/bash
exec > /var/log/startup.log 2>&1

echo "Script iniziato"
echo "Ciao dal Terraform" > /home/user/saluto.txt

apt-get update -y
apt-get install -y nginx

echo "Script completato

EOT

}

resource "google_compute_disk" "attached_disk" {
  count    = var.google_compute_disk != null ? 1 : 0
  name     = var.google_compute_disk.name
  type     = var.google_compute_disk.type
  size     = var.google_compute_disk.size
  zone     = coalesce(var.google_compute_disk.zone, var.zone)
  project  = var.project
  labels   = var.google_compute_disk.labels
}

resource "google_compute_attached_disk" "disk_attach" {
  count  = var.google_compute_disk != null ? 1 : 0
  disk   = google_compute_disk.attached_disk[0].self_link
  instance = google_compute_instance.vm.id
}
