resource "google_kms_key_ring" "sops_keyring" {
  project  = local.project
  name     = "sops-key-ring"
  location = "global"

  depends_on = [
    google_project_service.service,
  ]
}

resource "google_kms_crypto_key" "sops_key" {
  name     = "sops-key"
  key_ring = google_kms_key_ring.sops_keyring.id
  purpose  = "ENCRYPT_DECRYPT"
}
