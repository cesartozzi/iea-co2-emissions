# Terraform Configuration Breakdown

This document explains each section of the `main.tf` and `variables.tf` files used to deploy Mage to Google Cloud Platform (GCP).

## `main.tf`

The `main.tf` file contains the primary Terraform configuration for deploying Mage to GCP. It includes provider settings, resource definitions, and output configurations.

### Terraform Block

```hcl
terraform {
  required_version = ">= 0.14"
  required_providers {
    google = ">= 3.3"
  }
}
```

- **`required_version`**: Specifies the minimum Terraform version required for this configuration.
- **`required_providers`**: Defines the provider(s) used. In this case, it’s the Google Cloud provider with version `>= 3.3`.

### Provider Block

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}
```

- **`provider "google"`**: Configures the Google Cloud provider.
  - **`project`**: Sets the GCP project ID from the variable `project_id`.
  - **`region`**: Sets the default region for resources from the variable `region`.

### Enable APIs

```hcl
resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "cloudrun" {
  service = "run.googleapis.com"
}

resource "google_project_service" "vpcaccess" {
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "bigquery" {
  service = "bigquery.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  service = "storage.googleapis.com"
}
```

- **`google_project_service`**: Enables APIs needed for the deployment.
  - **`service`**: Specifies the API to be enabled.
  - **`disable_on_destroy`**: Controls whether the API should be disabled when the resource is destroyed. Set to `false` to keep the API enabled.

### Cloud Run Service

```hcl
resource "google_cloud_run_service" "run_service" {
  name     = var.app_name
  location = var.region

  template {
    spec {
      containers {
        image = var.docker_image
        ports {
          container_port = 6789
        }
        resources {
          limits = {
            cpu    = var.container_cpu
            memory = var.container_memory
          }
        }
        env {
          name  = "GCP_PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "GCP_REGION"
          value = var.region
        }
        env {
          name  = "GCP_SERVICE_NAME"
          value = var.app_name
        }
        env {
          name  = "ULIMIT_NO_FILE"
          value = 16384
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1"
        "run.googleapis.com/cpu-throttling" = false
        "run.googleapis.com/execution-environment" = "gen2"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    annotations = {
      "run.googleapis.com/launch-stage" = "BETA"
      "run.googleapis.com/ingress"      = "all"
    }
  }

  autogenerate_revision_name = true
}
```

- **`google_cloud_run_service`**: Defines a Cloud Run service.
  - **`name`**: Sets the name of the Cloud Run service from the variable `app_name`.
  - **`location`**: Specifies the region where the service will be deployed.
  - **`template`**: Contains configuration for the container.
    - **`spec`**: Defines the container specification.
      - **`containers`**: Configures the container settings, including the image, ports, and resources.
      - **`env`**: Defines environment variables for the container.
  - **`metadata`**: Includes annotations to control scaling and execution environment.
  - **`traffic`**: Routes all traffic to the latest revision of the service.
  - **`autogenerate_revision_name`**: Automatically generates a revision name for the service.

### IAM Policy Binding for Cloud Run

```hcl
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
```

- **`google_cloud_run_service_iam_member`**: Configures IAM policy for the Cloud Run service.
  - **`role`**: Grants the `roles/run.invoker` role to `allUsers`, making the service publicly accessible.

### Output

```hcl
output "service_url" {
  value = google_cloud_run_service.run_service.status[0].url
}
```

- **`output "service_url"`**: Displays the URL of the deployed Cloud Run service.

## `variables.tf`

The `variables.tf` file defines variables used in the `main.tf` configuration. This allows for flexible and reusable Terraform configurations.

### Variable Definitions

```hcl
variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "mage-data-prep"
}

variable "container_cpu" {
  description = "Container cpu"
  default     = "2000m"
}

variable "container_memory" {
  description = "Container memory"
  default     = "2G"
}

variable "project_id" {
  type        = string
  description = "The name of the project"
  default     = "iea-co2-project"
}

variable "region" {
  type        = string
  description = "The default compute region"
  default     = "europe-southwest1"
}

variable "zone" {
  type        = string
  description = "The default compute zone"
  default     = "europe-southwest1-c"
}

variable "repository" {
  type        = string
  description = "The name of the Artifact Registry repository to be created"
  default     = "mage-data-prep"
}

variable "docker_image" {
  type        = string
  description = "The docker image to deploy to Cloud Run."
  default     = "mageai/mageai:latest"
}

variable "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  type        = string
  default     = ""
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = false
}
```

- **`variable "app_name"`**: Specifies the name of the application.
- **`variable "container_cpu"`**: Sets the CPU limit for the container.
- **`variable "container_memory"`**: Sets the memory limit for the container.
- **`variable "project_id"`**: Defines the GCP project ID.
- **`variable "region"`**: Sets the default region for resources.
- **`variable "zone"`**: Defines the default compute zone.
- **`variable "repository"`**: Specifies the name of the Artifact Registry repository.
- **`variable "docker_image"`**: Defines the Docker image to deploy.
- **`variable "domain"`**: Specifies the domain name for the load balancer (used if `ssl` is `true`).
- **`variable "ssl"`**: Determines whether to use HTTPS and provision a managed certificate.

This detailed breakdown should help you understand and manage your Terraform configuration more effectively. Feel free to ask if you have any more questions or need further clarification!