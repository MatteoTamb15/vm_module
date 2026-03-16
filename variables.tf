variable "name" {
  description = "Il nome della VM."
  type        = string
}

variable "project" {
  description = "L'ID del progetto GCP."
  type        = string
}

variable "zone" {
  description = "La zona GCP in cui creare la VM."
  type        = string
}

variable "machine_type" {
  description = "Il tipo di macchina per la VM."
  type        = string
  default     = "e2-medium"
}

variable "os_type" {
  description = "Il tipo di sistema operativo. Valori possibili: 'linux' o 'windows'."
  type        = string
  validation {
    condition     = contains(["linux", "windows"], var.os_type)
    error_message = "Il valore per os_type deve essere 'linux' o 'windows'."
  }
}

variable "image_family_linux" {
  description = "La famiglia di immagini per le VM Linux."
  type        = string
  default     = "debian-11"
}

variable "image_project_linux" {
  description = "Il progetto GCP per l'immagine Linux."
  type        = string
  default     = "debian-cloud"
}

variable "image_family_windows" {
  description = "La famiglia di immagini per le VM Windows."
  type        = string
  default     = "windows-server-2022-dc"
}

variable "image_project_windows" {
  description = "Il progetto GCP per l'immagine Windows."
  type        = string
  default     = "windows-cloud"
}

variable "image" {
  description = "L'immagine specifica da usare per la VM. Se null, verrà usata la famiglia di immagini."
  type        = string
  default     = null
}

variable "google_compute_disk" {
  description = "Configuration for additional disk (optional)"
  type = object({
    name   = string
    labels = map(string)
    size   = optional(number)
    type   = optional(string)
    zone   = optional(string)
  })
  default = null
}

variable "boot_disk" {
  description = "Configurazione del disco di avvio."
  type = object({
    initialize_params = object({
      image = optional(string)
      size  = optional(number)
      type  = optional(string)
    })
  })
}

variable "tags" {
  description = "Una lista di tag da associare alla VM."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Un mappa di etichette da associare alla VM."
  type        = map(string)
  default     = {}
}

variable "network_interface" {
  type = object({
    network = string
  })
  default = { network = "default" } 
}

variable "service_account" {
  type = object({
    scopes = list(string)
  })
  default = { scopes = ["https://www.googleapis.com/auth/cloud-platform"] }
}

