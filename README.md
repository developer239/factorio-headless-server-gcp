# Factorio Headless Server on GCP with Terraform

Deploy Factorio headless server on Google Cloud Platform using Terraform. Designed for small gaming groups with simple
start/stop controls.

## Setup

### 1. Authentication

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud services enable compute.googleapis.com
```

```bash
gcloud auth application-default login
```

```bash
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
```

### 2. Configuration

```bash
git clone <your-repo>
cd factorio-headless-server-gcp
```

Update configuration in: `terraform.tfvars`

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

Deployment takes 3-5 minutes.

## Server Control

### Start Server

```bash
./scripts/start-server.sh
```

**Output shows connection IP for players**

### Stop Server

```bash
./scripts/stop-server.sh
```

**Saves game and stops billing**

### Check Status

```bash
./scripts/server-status.sh
```

**Shows server status, logs, and connection info**

## Player Connection

Players connect using the IP address shown by the start script:

1. Open Factorio
2. Multiplayer -> Connect to Address
3. Enter: `[SERVER_IP]:34197`
4. Enter password (if configured)

## Management Tasks

### Access Server

```bash
# SSH to server
terraform output ssh_command

# View container logs
gcloud compute ssh factorio-server --zone=europe-west4-a --command="docker logs factorio"

# Resource usage
gcloud compute ssh factorio-server --zone=europe-west4-a --command="docker stats factorio"
```

### Save File Management

```bash
# Download save
gcloud compute scp factorio-server:/opt/factorio/saves/terraform-world.zip ./backup.zip --zone=europe-west4-a

# Upload save
gcloud compute scp ./my-save.zip factorio-server:/opt/factorio/saves/ --zone=europe-west4-a

# List saves
gcloud compute ssh factorio-server --zone=europe-west4-a --command="ls /opt/factorio/saves/"
```

## File Structure

```
factorio-headless-server-gcp/
├── main.tf                 # GCP infrastructure
├── variables.tf            # Configuration variables
├── outputs.tf              # Server connection info
├── terraform.tfvars        # Your configuration
├── startup-script.sh       # Server setup script
└── scripts/
    ├── start-server.sh     # Start server
    ├── stop-server.sh      # Stop server
    └── server-status.sh    # Server status
```
