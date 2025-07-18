resource "google_storage_bucket" "nexus_blob_storage" {
  name    = var.bucket_name
  project = var.project_id
  location = var.region
  storage_class = "STANDARD"
  public_access_prevention = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}