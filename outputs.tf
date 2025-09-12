output "server_ip" {
  value       = google_compute_address.factorio_ip.address
  description = "External IP address of Factorio server"
}

output "connection_string" {
  value       = "${google_compute_address.factorio_ip.address}:34197"
  description = "Direct connection string for players"
}

output "http_api_url" {
  value       = "http://${google_compute_address.factorio_ip.address}:8080"
  description = "HTTP API endpoint for server management"
}

output "instance_name" {
  value       = google_compute_instance.factorio_server.name
  description = "Name of the Factorio server instance"
}

output "zone" {
  value       = var.zone
  description = "Zone where the server is deployed"
}

output "management_service_account_email" {
  value       = google_service_account.factorio_management_sa.email
  description = "Email of the management service account for creating keys"
}
