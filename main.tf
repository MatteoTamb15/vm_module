# Ottiene l'immagine più recente per la famiglia specificata solo se image non fornita
data "google_compute_image" "vm_image" {
  count = var.image == null ? 1 : 0
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
      image = var.image != null ? var.image : data.google_compute_image.vm_image[0].self_link
      size  = var.boot_disk.initialize_params.size
      type  = var.boot_disk.initialize_params.type
    }
  }

  dynamic "network_interface" {
    for_each = length(keys(var.network_interface)) > 0 ? [var.network_interface] : []
    content {
      network = network_interface.value.network
      access_config {}
    }
  }

  dynamic "service_account" {
    for_each = length(var.service_account.scopes) > 0 ? [var.service_account] : []
    content {
      scopes = service_account.value.scopes
    }
  }
  metadata = {
  startup-script = file("${path.module}/../../startup.sh")
  }
  #metadata = {
  #startup-script = <<-EOT
  #  #!/bin/bash
  #  # Crea utente e gruppo
  #  USER_NAME="matteo"
  #  GROUP_NAME="gruppo1"#
  #  # Crea il gruppo se non esiste
  #  if ! getent group "$GROUP_NAME" > /dev/null 2>&1; then
  #      groupadd "$GROUP_NAME"
  #  fi#
  #  # Crea utente e imposta password
  #  USER_PASSWORD="password" 
  #  if ! id "$USER_NAME" > /dev/null 2>&1; then
  #      useradd -m -s /bin/bash -g "$GROUP_NAME" "$USER_NAME"
  #  fi
  #  echo "$USER_NAME:$USER_PASSWORD" | chpasswd
#
  #  # Aggiunge utente a sudo
  #  usermod -aG sudo "$USER_NAME" || true
#
  #  # Setup SSH directory
  #  mkdir -p "/home/$USER_NAME/.ssh"
  #  chmod 700 "/home/$USER_NAME/.ssh"
  #  touch "/home/$USER_NAME/.ssh/authorized_keys"
  #  chmod 600 "/home/$USER_NAME/.ssh/authorized_keys"
  #  chown -R "$USER_NAME:$GROUP_NAME" "/home/$USER_NAME/.ssh"
#
  #  # ABILITA password auth per primo login (disabilita dopo setup SSH)
  #  sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config || true
  #  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config || true
  #  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config || true
  #  systemctl restart sshd
#
  #  # Log
  #  echo "$(date): User '$USER_NAME' e gruppo '$GROUP_NAME'" >> /var/log/startup-script.log
  #  cat /var/log/startup-script.log
#
  #  EOT
  #}
}


resource "google_compute_disk" "attached_disk" {
  count = var.google_compute_disk != null ? 1 : 0
  name  = "${var.name}-disk"
  type  = try(var.google_compute_disk.type, "pd-standard")
  size  = try(var.google_compute_disk.size, 10)
  zone  = var.zone
  labels = try(var.google_compute_disk.labels, {})
}

resource "google_compute_attached_disk" "disk_attach" {
  count  = var.google_compute_disk != null ? 1 : 0
  disk   = google_compute_disk.attached_disk[0].self_link
  instance = google_compute_instance.vm.id
}

