locals {
  services = toset([
    "sqladmin.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "appengine.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "vpcaccess.googleapis.com",
    "cloudscheduler.googleapis.com",
    "redis.googleapis.com"
  ])
}

resource "google_project_service" "service" {
  for_each = local.services
  project  = local.project
  service  = each.value
}

data "google_project" "project" {
}
