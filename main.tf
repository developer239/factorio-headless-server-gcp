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

# Custom role with minimal permissions for server management
resource "google_project_iam_custom_role" "factorio_operator" {
  role_id     = "factorioServerOperator"
  title       = "Factorio Server Operator"
  description = "Minimal permissions to start/stop Factorio server"
  permissions = [
    "compute.instances.get",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.list",
    "compute.zones.get",
    "compute.zones.list"
  ]
}

# Service account for server management (start/stop scripts)
resource "google_service_account" "factorio_management_sa" {
  account_id   = "factorio-management-sa"
  display_name = "Factorio Server Management Service Account"
}

# Grant custom role instead of broad instanceAdmin role
resource "google_project_iam_member" "factorio_management_custom" {
  project = var.project_id
  role    = google_project_iam_custom_role.factorio_operator.id
  member  = "serviceAccount:${google_service_account.factorio_management_sa.email}"
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

# HTTP API access for remote management
resource "google_compute_firewall" "factorio_http_api" {
  name    = "allow-factorio-http-api"
  network = google_compute_network.factorio_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]  # HTTP API
  }

  source_ranges = ["0.0.0.0/0"]  # Public access
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
      image = "cos-cloud/cos-stable"
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
    gce-container-declaration = templatefile("${path.module}/container-spec.yaml", {
      server_name        = var.server_name
      server_description = var.server_description
      max_players        = var.max_players
      admin_users        = jsonencode(var.admin_users)
    })
  }

  labels = {
    container-vm = "cos-stable"
  }

  scheduling {
    preemptible       = false
    automatic_restart = true
  }

  # Allow stopping for cost savings
  allow_stopping_for_update = true
}
