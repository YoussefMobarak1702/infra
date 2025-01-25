terraform {
    backend "gcs" { 
      bucket  = "terraform-state-jb-cicdprjct"
      prefix  = "prod"
    }
}

provider "google" {
  project = var.project
  region = var.region
}