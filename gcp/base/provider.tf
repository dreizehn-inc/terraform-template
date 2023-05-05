provider "google" {
  project = local.project
  region  = local.location
}

terraform {
  backend "gcs" {
    bucket = local.tf_state_bucket
  }
}
