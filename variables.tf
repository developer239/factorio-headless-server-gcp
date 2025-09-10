variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west4"  # Netherlands
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-west4-a"
}

variable "machine_type" {
  description = "Instance type for Factorio server (e2-small, e2-medium, etc.)"
  type        = string
}

variable "server_name" {
  description = "Name for the Factorio server in-game"
  type        = string
}

variable "server_description" {
  description = "Description for the Factorio server"
  type        = string
  default     = "Build something special!"
}

variable "max_players" {
  description = "Maximum number of players"
  type        = number
  default     = 6
}

variable "game_password" {
  description = "Password for the Factorio server (leave empty for no password)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_users" {
  description = "List of Factorio usernames who should have admin privileges"
  type = list(string)

  validation {
    condition = alltrue([
      for user in var.admin_users : can(regex("^[a-zA-Z0-9_-]+$", user))
    ])
    error_message = "Admin usernames must contain only letters, numbers, underscores, and hyphens."
  }
}
