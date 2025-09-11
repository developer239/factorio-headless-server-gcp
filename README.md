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
- `./scripts/server-status.sh` - Check server status

### Save File Management

```bash
# Download save
gcloud compute scp factorio-server:/opt/factorio/saves/terraform-world.zip ./backup.zip --zone=europe-west4-a

# Upload save
gcloud compute scp ./my-save.zip factorio-server:/opt/factorio/saves/ --zone=europe-west4-a

# List saves
gcloud compute ssh factorio-server --zone=europe-west4-a --command="ls /opt/factorio/saves/"
```

## Troubleshooting

- `gcloud compute ssh factorio-server --zone=europe-west4-a` ssh into the server
- `gcloud compute ssh factorio-server --zone=europe-west4-a --tunnel-through-iap` ssh using IAP
- `sudo systemctl status docker` check Docker status
- `sudo docker logs factorio` view Factorio container logs
