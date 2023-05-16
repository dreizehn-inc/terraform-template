locals {
  job_roles = [
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

  cloud_run_jobs = {
    sample_batch = { name = "sample-batch", args = ["task", "sample-batch", "run"] },
  }

  cloud_run_job_schedulers = {
    sample_batch = { name = "sample-batch", schedule = "0 0 * * *" },
  }
}

resource "google_service_account" "job" {
  account_id   = "job"
  display_name = "Job Service Account"

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_project_iam_member" "job" {
  for_each = toset(local.job_roles)
  project  = local.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.job.email}"
}

resource "google_cloud_run_v2_job" "jobs" {
  for_each = local.cloud_run_jobs
  name     = each.value.name
  location = local.location
  project  = local.project

  template {
    template {
      service_account = google_service_account.job.email

      containers {
        image = "${local.location}-docker.pkg.dev/${local.project}/${google_artifact_registry_repository.registry.repository_id}/backend:latest"
        args  = each.value.args

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
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.db_password.secret_id
              version = google_secret_manager_secret_version.db_password.version
            }
          }
        }
      }

      vpc_access {
        connector = google_vpc_access_connector.connector.id
        egress    = "ALL_TRAFFIC"
      }
    }

  }

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image,
    ]
  }
}

resource "google_service_account" "job_invoker" {
  account_id   = "job-invoker"
  display_name = "Job Invoker Service Account"

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_project_iam_member" "job_invoker" {
  project = local.project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.job_invoker.email}"
}

resource "google_cloud_scheduler_job" "jobs" {
  for_each         = local.cloud_run_job_schedulers
  provider         = google-beta
  name             = each.value.name
  schedule         = each.value.schedule
  attempt_deadline = "320s"
  region           = local.location
  project          = local.project

  retry_config {
    retry_count = 3
  }

  http_target {
    http_method = "POST"
    uri         = "https://${local.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${data.google_project.project.number}/jobs/${each.value.name}:run"

    oauth_token {
      service_account_email = google_service_account.job_invoker.email
    }
  }

  depends_on = [
    google_cloud_run_v2_job.jobs,
  ]
}
