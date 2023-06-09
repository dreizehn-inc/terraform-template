locals {
  backend_roles = [
    "roles/cloudsql.client",
    "roles/storage.admin",
    "roles/firebase.admin",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountTokenCreator",
    "roles/pubsub.publisher",
    "roles/pubsub.subscriber",
    "roles/cloudprofiler.agent",
    "roles/cloudkms.signerVerifier"
  ]

  cloud_run_services = {
    api = { name = "api", args = ["http-server", "run"], min_scale = 0, max_scale = 5, },
  }
}

resource "google_service_account" "backend" {
  account_id   = "app-backend"
  display_name = "Backend Service Account"

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_project_iam_member" "backend" {
  for_each = toset(local.backend_roles)
  project  = local.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_cloud_run_service" "services" {
  for_each = local.cloud_run_services
  name     = each.value.name
  location = local.location
  project  = local.project

  template {
    spec {
      service_account_name = google_service_account.backend.email

      containers {
        image = "${local.registry_path}/backend:latest"
        ports {
          container_port = 8080
        }
        args = each.value.args

        env {
          name  = "ENV"
          value = local.env
        }
        env {
          name  = "GCP_PROJECT_ID"
          value = local.project
        }
        env {
          name  = "SERVICE_NAME"
          value = each.value.name
        }
        env {
          name  = "MIN_LOG_SEVERITY"
          value = "DEBUG"
        }
        env {
          name  = "DB_HOST"
          value = "unix(/cloudsql/${google_sql_database_instance.master_instance.connection_name})"
        }
        env {
          name  = "DB_DATABASE"
          value = google_sql_database.database.name
        }
        env {
          name  = "DB_USER"
          value = google_sql_user.app_user.name
        }
        env {
          name = "DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.db_password.secret_id
              key  = google_secret_manager_secret_version.db_password.version
            }
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"      = each.value.min_scale
        "autoscaling.knative.dev/maxScale"      = each.value.max_scale
        "run.googleapis.com/cpu-throttling"     = each.value.min_scale == 0 ? "true" : "false"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.master_instance.connection_name
        "run.googleapis.com/client-name"        = "terraform"
      }
    }
  }

  autogenerate_revision_name = true

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
    ]
  }
}

resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = "api"
  location = local.location
  role     = "roles/run.invoker"
  member   = "allUsers"

  depends_on = [
    google_project_service.service,
  ]
}
