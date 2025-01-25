resource "google_storage_bucket" "tbuk" {
  project = var.project
  name = "${var.data-project}-tbuk"
  force_destroy = false
  uniform_bucket_level_access = true
  location = var.region
}