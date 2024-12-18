provider "google" {
  project = ""
  region  = ""
}

terraform {
  backend "gcs" {
    bucket = ""
    prefix = ""
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}
