resource "google_redis_instance" "redis" {
  name           = "redis"
  tier           = "STANDARD_HA"
  memory_size_gb = 1

  location_id             = "asia-northeast1-a"
  alternative_location_id = "asia-northeast1-c"

  redis_version = "REDIS_6_X"
  display_name  = "redis"

  authorized_network = google_compute_network.network.id

  depends_on = [
    google_project_service.service,
  ]
}
