locals {
  project               = ""
  location              = ""
  env                   = ""
  github_repositories   = []
  gcs_asset_bucket_name = ""
  db_tier               = ""
  db_disk_type          = ""
  db_availability_type  = ""
}

data "sops_file" "secrets" {
  source_file = "./secrets/sops_secrets_encrypted.json"
}
