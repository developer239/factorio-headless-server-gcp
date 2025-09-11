output "server_ip" {
  value       = google_compute_address.factorio_ip.address
  description = "External IP address of Factorio server"
}

output "connection_string" {
  value       = "${google_compute_address.factorio_ip.address}:34197"
  description = "Direct connection string for players"
}

output "instance_name" {
  value       = google_compute_instance.factorio_server.name
  description = "Name of the Factorio server instance"
}

output "zone" {
  value       = var.zone
  description = "Zone where the server is deployed"
}

output "ssh_command" {
  value       = "gcloud compute ssh ${google_compute_instance.factorio_server.name} --zone=${var.zone}"
  description = "SSH command to connect to the server"
}

output "management_service_account_email" {
  value       = google_service_account.factorio_management_sa.email
  description = "Email of the management service account for creating keys"
}
