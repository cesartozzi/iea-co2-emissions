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
  default     = "gcr.io/iea-co2-project/mageprod:latest"
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