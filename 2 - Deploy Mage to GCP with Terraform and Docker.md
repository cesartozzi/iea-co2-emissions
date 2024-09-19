# Deploy Mage to GCP

This guide outlines the steps to deploy Mage to Google Cloud Platform (GCP) using Terraform and remote access.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Setup GCP Roles](#setup-gcp-roles)
- [Enable APIs](#enable-apis)
- [Install Terraform in GitHub Codespace](#install-terraform-in-github-codespace)
- [Manage Keys Securely](#manage-keys-securely)
- [Create Terraform Configuration](#create-terraform-configuration)
- [Deploy Mage](#deploy-mage)
- [Accessing the Mage UI](#accessing-the-mage-ui)
- [Troubleshooting](#troubleshooting)

## Prerequisites

1. A GCP project (e.g., `iea-co2-project`)
2. Access to the Google Cloud Console
3. GitHub Codespace environment

## Setup GCP Roles

1. Go to IAM in the Google Cloud Console.
2. Choose the service account and add the following roles:
   - `roles/run.admin`
   - `roles/iam.securityAdmin`

3. Verify Permissions:
   ```bash
   gcloud projects add-iam-policy-binding iea-co2-project \
     --member='user:YOUR_EMAIL' \
     --role='roles/run.admin'

   gcloud projects add-iam-policy-binding iea-co2-project \
     --member='user:YOUR_EMAIL' \
     --role='roles/iam.securityAdmin'
   ```

## Enable APIs

1. Enable the required APIs:
   - [Service Usage API](https://console.developers.google.com/apis/api/serviceusage.googleapis.com/overview?project=85467223733)
   - [Cloud Resource Manager API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview?project=85467223733)

## Install Terraform in GitHub Codespace

1. Install Terraform:
   ```bash
   sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform
   ```

## Manage Keys Securely

1. Create a secure directory for storing keys:
   ```bash
   mkdir -p ~/.gcloud/keys
   ```

2. Download and save the JSON key file from the service account:
   ```bash
   cd ~/.gcloud/keys
   nano my-creds.json
   ```

3. Set the environment variable to point to the new location of the key file:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcloud/keys/my-creds.json"
   ```

4. In VSCode, add the Terraform extension for better integration.

## Create Terraform Configuration

1. Create a directory for Terraform files:
   ```bash
   mkdir terraform
   cd terraform
   ```

2. Create and open the `main.tf` file:
   ```bash
   touch main.tf
   code main.tf
   ```

2. Create main.tf

4. Create variables.tf

## Deploy Mage

1. Validate the Terraform configuration:
   ```bash
   terraform validate
   ```

2. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

3. If there are errors, use the following commands to troubleshoot and set up authentication:
   ```bash
   gcloud auth activate-service-account ACCOUNT --key-file=KEY_FILE
   # Replace ACCOUNT with the service account email and KEY_FILE with the path to the JSON key file.
   gcloud auth activate-service-account 85467223733-compute@developer.gserviceaccount.com --key-file="$HOME/.gcloud/keys/my-creds.json"

   gcloud projects add-iam-policy-binding iea-co2-project \
     --member='serviceAccount:85467223733-compute@developer.gserviceaccount.com' \
     --role='roles/run.admin'

   gcloud projects add-iam-policy-binding iea-co2-project \
     --member='serviceAccount:85467223733-compute@developer.gserviceaccount.com' \
     --role='roles/iam.securityAdmin'

   gcloud config set account ACCOUNT_EMAIL
   ```

## Accessing the Mage UI

1. After deployment, Terraform will output the external IP or URL of the Cloud Run service.
2. Find this URL in the Terraform output or by visiting Google Cloud Console → Cloud Run → Services.
3. Open the URL in a browser to access Mage’s web UI, where you can start writing code and building pipelines.

## Troubleshooting

1. If you encounter issues during `terraform apply`, ensure that your GCP credentials are correctly configured and that you have the necessary permissions.

2. If you see errors related to authentication or permissions, review the IAM roles and service account configurations.

3. For further assistance, consult the [Terraform documentation](https://registry.terraform.io/providers/hash