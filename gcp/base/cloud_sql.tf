resource "google_sql_database_instance" "master_instance" {
  name             = local.db_master_instance_name
  database_version = "MYSQL_8_0"
  region           = local.location

  settings {
    tier              = local.db_tier
    disk_type         = local.db_disk_type
    availability_type = local.db_availability_type

    database_flags {
      name  = "character_set_server"
      value = "utf8mb4"
    }

    backup_configuration {
      location           = "asia"
      enabled            = true
      binary_log_enabled = true
    }

  }

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_sql_database" "database" {
  name     = local.db_database_name
  instance = google_sql_database_instance.master_instance.name
}

resource "random_password" "db_password" {
  length = 16
}

resource "google_sql_user" "app_user" {
  name     = local.db_database_user_name
  instance = google_sql_database_instance.master_instance.name
  password = random_password.db_password.result
}
