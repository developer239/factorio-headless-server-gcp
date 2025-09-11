# Factorio Headless Server on GCP with Terraform

Deploy Factorio headless server on Google Cloud Platform using Terraform. Designed for small gaming groups with simple
start/stop controls.

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

```bash
git clone https://github.com/developer239/factorio-headless-server-gcp.git
cd factorio-headless-server-gcp
```

Create and configure: `terraform.tfvars`

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

## Troubleshooting

How to SSH into the server:

```bash
gcloud compute ssh factorio-server --zone=europe-west4-a
```

or:

```bash
gcloud compute ssh factorio-server --zone=europe-west4-a --tunnel-through-iap
```

### Once you are on the server

Check Docker status:

```bash
sudo systemctl status docker
```

Check Factorio container logs:

```bash
sudo docker logs factorio
```
