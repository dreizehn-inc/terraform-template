resource "google_artifact_registry_repository" "registry" {
  location      = local.location
  repository_id = local.repository_id
  format        = "DOCKER"

  depends_on = [
    google_project_service.service,
  ]
}
