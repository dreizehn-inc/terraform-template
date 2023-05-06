locals {
  project               = ""
  location              = ""
  env                   = ""
  tf_state_bucket       = ""
  repository_id         = ""
  github_repositories   = []
  vpc_network_name      = ""
  gcs_asset_bucket_name = ""


  db_master_instance_name    = ""
  db_database_name           = ""
  db_database_user_name      = ""
  db_tier                    = ""
  db_disk_type               = ""
  db_availability_type       = ""
  db_password_secret_version = "1"
}

data "sops_file" "secrets" {
  source_file = "./secrets/sops_secrets_encrypted.json"
}
