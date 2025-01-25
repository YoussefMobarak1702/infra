terraform {
    backend "gcs" { 
      bucket  = "terraform-state-jb-cicdprjct"
    }
}

provider "google" {
  project = var.project
  region = var.region
}