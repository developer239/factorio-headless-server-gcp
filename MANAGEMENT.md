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

- `./scripts/server-status.sh` - Check server status
- `./scripts/start-server.sh` - Start the Factorio server
- `./scripts/stop-server.sh` - Stop the Factorio server
