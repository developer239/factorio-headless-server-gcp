provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Service account for server
resource "google_service_account" "factorio_sa" {
  account_id   = "factorio-server-sa"
  display_name = "Factorio Server Service Account"
}

# Static IP for consistent server address
resource "google_compute_address" "factorio_ip" {
  name         = "factorio-server-ip"
  region       = var.region
  address_type = "EXTERNAL"
}

# VPC Network
resource "google_compute_network" "factorio_vpc" {
  name                    = "factorio-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Subnet
resource "google_compute_subnetwork" "factorio_subnet" {
  name          = "factorio-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.factorio_vpc.id

  private_ip_google_access = true
}

# Firewall rules for Factorio
resource "google_compute_firewall" "factorio_game" {
  name    = "allow-factorio-game"
  network = google_compute_network.factorio_vpc.name

  allow {
    protocol = "udp"
    ports    = ["34197"]
  }

  allow {
    protocol = "tcp"
    ports    = ["27015"]  # RCON
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["factorio-server"]
}

# SSH access (restricted to Google Cloud IAP)
resource "google_compute_firewall" "ssh_admin" {
  name    = "allow-ssh-admin"
  network = google_compute_network.factorio_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]  # Google Cloud IAP
  target_tags   = ["factorio-server"]
}

# Main server instance
resource "google_compute_instance" "factorio_server" {
  name         = "factorio-server"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["factorio-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = google_compute_network.factorio_vpc.id
    subnetwork = google_compute_subnetwork.factorio_subnet.id

    access_config {
      nat_ip = google_compute_address.factorio_ip.address
    }
  }

  service_account {
    email  = google_service_account.factorio_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = templatefile("${path.module}/startup-script.sh", {
      server_name        = var.server_name
      server_description = var.server_description
      max_players        = var.max_players
      game_password      = var.game_password
      admin_users        = var.admin_users
    })
  }

  scheduling {
    preemptible       = false
    automatic_restart = true
  }

  # Allow stopping for cost savings
  allow_stopping_for_update = true
}
