locals {
  github_actions_roles = [
    "roles/cloudsql.client",
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin",
    "roles/artifactregistry.writer"
  ]
}

resource "google_service_account" "github_actions" {
  project      = local.project
  account_id   = "github-actions-agent"
  display_name = "A service account for GitHub Actions"

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_project_service" "project" {
  project = local.project
  service = "iamcredentials.googleapis.com"

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_iam_workload_identity_pool" "github_actions" {
  provider                  = google-beta
  project                   = local.project
  workload_identity_pool_id = "gh-oidc-pool"
  display_name              = "gh-oidc-pool"
  description               = "Workload Identity Pool for GitHub Actions"

  depends_on = [
    google_project_service.service,
  ]
}


resource "google_iam_workload_identity_pool_provider" "github_actions" {
  provider                           = google-beta
  project                            = local.project
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "github-actions"
  description                        = "OIDC identity pool provider for GitHub Actions"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "repository" {
  for_each           = { for i in local.github_repositories : i => i }
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository/${each.value}"
}


resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset(local.github_actions_roles)
  project  = local.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.github_actions.email}"
}
