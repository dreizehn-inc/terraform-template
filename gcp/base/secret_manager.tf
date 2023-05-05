resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret" {
  secret = google_secret_manager_secret.db_password.id

  secret_data = random_password.db_password.result
}
