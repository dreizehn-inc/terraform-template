resource "google_storage_bucket" "asset_bucket" {
  name          = local.gcs_asset_bucket_name
  location      = local.location
  storage_class = "STANDARD"

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE", "OPTIONS"]
    response_header = ["content-type", "cache-control", "x-requested-with"]
    max_age_seconds = 3600
  }
}
