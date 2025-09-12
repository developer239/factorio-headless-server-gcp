# How To Manage Factorio Server

Prerequisites:

- Clone the repository
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed

1. Paste the service account key JSON file created during Terraform deployment into the repository root and name it
   `factorio-management-key.json`.
2. Authenticate gcloud using the service account key:

```bash
gcloud auth activate-service-account --key-file=factorio-management-key.json
```

3. Set your project:

```bash
gcloud config set project private-factorio-server
```

4. You are good to go! Use the scripts in the `scripts` directory to manage your Factorio server.

**Commands:**

- `./scripts/start-server.sh` - Start the Factorio server  
- `./scripts/stop-server.sh` - Stop the Factorio server

## HTTP API Management

Once the server is running, you can manage it remotely via HTTP API on port 8080:

### Get Server Information
```bash
# Get server IP from terraform
SERVER_IP=$(cd /path/to/terraform && terraform output -raw server_ip)

# Check server status
curl http://$SERVER_IP:8080/factorio/status

# Get API URL directly  
curl http://$SERVER_IP:8080/factorio/time
```

### Save Management
```bash
# List all saves
curl http://$SERVER_IP:8080/factorio/saves

# Load a specific save
curl -X POST http://$SERVER_IP:8080/factorio/load/default

# Upload and auto-load save
curl -X POST http://$SERVER_IP:8080/factorio/upload-save \
  -F "saveFile=@/path/to/save.zip" \
  -F "autoLoad=true"
```

### Game Controls
```bash
# Pause/unpause
curl -X POST http://$SERVER_IP:8080/factorio/pause
curl -X POST http://$SERVER_IP:8080/factorio/unpause

# Speed controls
curl -X POST http://$SERVER_IP:8080/factorio/speed/slow
curl -X POST http://$SERVER_IP:8080/factorio/speed/normal
curl -X POST http://$SERVER_IP:8080/factorio/speed/fast
```
