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

output "api_usage" {
  value = <<-EOT
Check Server Status
curl http://${google_compute_address.factorio_ip.address}:8080/factorio/status

Pause Game
curl -X POST http://${google_compute_address.factorio_ip.address}:8080/factorio/pause

Unpause Game
curl -X POST http://${google_compute_address.factorio_ip.address}:8080/factorio/unpause

Set Game Speed Slow
curl -X POST http://${google_compute_address.factorio_ip.address}:8080/factorio/speed/slow

Set Game Speed Normal
curl -X POST http://${google_compute_address.factorio_ip.address}:8080/factorio/speed/normal

Set Game Speed Fast
curl -X POST http://${google_compute_address.factorio_ip.address}:8080/factorio/speed/fast

List Save Files
curl http://${google_compute_address.factorio_ip.address}:8080/factorio/saves

Load Save File
curl -X POST http://${google_compute_address.factorio_ip.address}:8080/factorio/load/SAVE_NAME

Upload and Load Save
curl -X POST http://${google_compute_address.factorio_ip.address}:8080/factorio/upload-save -F "saveFile=@/path/to/save.zip" -F "autoLoad=true"

Trigger Manual Save
curl -X POST http://${google_compute_address.factorio_ip.address}:8080/factorio/save

Get Server Time
curl http://${google_compute_address.factorio_ip.address}:8080/factorio/time
EOT
  description = "HTTP API usage examples with actual server IP"
}
