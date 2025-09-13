# Factorio Headless Server on GCP with Terraform

Deploy Factorio headless server on Google Cloud Platform using Terraform with HTTP API controls. Designed for small
gaming groups with remote server management via HTTP endpoints.

## Setup

### 1. Authentication

Login to GCP and set up your environment:

```bash
gcloud auth login
```

Set your project:

```bash
gcloud config set project YOUR_PROJECT_ID
```

Authenticate application default credentials so that Terraform can use them:

```bash
gcloud auth application-default login
```

Enable required APIs:

```bash
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
```

You might want to connect the project to your billing account.

### 2. Configuration

Create and configure: `terraform.tfvars` you only need to update _project_id_ to run the server.

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. Deploy

Note that the terraform state file will be created in the current directory and is not configured for remote storage.

```bash
terraform init
terraform apply
```

Deployment takes a couple of minutes.

Then you need to wait a couple of minutes for the Factorio server to start.

### 4. Get Server Information

After deployment, get connection details:

```bash
# Get server IP for Factorio game connections
terraform output connection_string

# Get HTTP API URL for management
terraform output http_api_url

# Get server IP only
terraform output server_ip
```

## Server Control

If you want to pass management commands using a service account key instead of application default credentials, create a
json key for the service account created by Terraform:

```bash
gcloud iam service-accounts keys create ./factorio-management-key.json \
  --iam-account=factorio-management-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com 
```

The management key can be used on any machine with gcloud installed:

```bash
gcloud auth activate-service-account --key-file=factorio-management-key.json
gcloud config set project YOUR_PROJECT_ID
```

**Commands:**

- `./scripts/start-server.sh` - Start the Factorio server
- `./scripts/stop-server.sh` - Stop the Factorio server

## Server Management via HTTP API

Once deployed, the server exposes an HTTP API on port 8080 for remote management. Get the API URL from terraform
outputs:

```bash
terraform output http_api_url
```

### Game Controls

**Check Server Status:**

```bash
curl http://YOUR_SERVER_IP:8080/factorio/status
```

**Pause/Unpause Game:**

```bash
curl -X POST http://YOUR_SERVER_IP:8080/factorio/pause
curl -X POST http://YOUR_SERVER_IP:8080/factorio/unpause
```

**Control Game Speed:**

```bash
curl -X POST http://YOUR_SERVER_IP:8080/factorio/speed/slow
curl -X POST http://YOUR_SERVER_IP:8080/factorio/speed/normal
curl -X POST http://YOUR_SERVER_IP:8080/factorio/speed/fast
```

### Save File Management

**List Save Files:**

```bash
curl http://YOUR_SERVER_IP:8080/factorio/saves
```

**Load Existing Save:**

```bash
curl -X POST http://YOUR_SERVER_IP:8080/factorio/load/SAVE_NAME
```

**Upload and Load Save File:**

```bash
curl -X POST http://YOUR_SERVER_IP:8080/factorio/upload-save \
  -F "saveFile=@/path/to/your/save.zip" \
  -F "autoLoad=true"
```

**Trigger Manual Save:**

```bash
curl -X POST http://YOUR_SERVER_IP:8080/factorio/save
```

**Get Server Time:**

```bash
curl http://YOUR_SERVER_IP:8080/factorio/time
```

## Troubleshooting

- `gcloud compute ssh factorio-server --zone=europe-west4-a --tunnel-through-iap` ssh using IAP
- `sudo systemctl status docker` check Docker status
- `sudo docker logs factorio` view Factorio container logs
- `cat /factorio/config/server-adminlist.json` view Factorio admin list
- `sudo docker ps | grep factorio` check container status
- `sudo docker logs $(sudo docker ps -q | head -1) --tail 50` view recent container logs
