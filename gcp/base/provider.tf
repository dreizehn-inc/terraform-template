provider "google" {
  project = local.project
  region  = local.location
}

terraform {
  backend "gcs" {
    bucket = local.tf_state_bucket
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7"
    }
  }
}
