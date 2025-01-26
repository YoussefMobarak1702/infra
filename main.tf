terraform {
  backend "gcs" {
    bucket = "terraform-state-jb-cicdprjct"
  }
}


provider "google" {
  project = var.project
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name     = "example-gke-cluster"
  location = var.region

  initial_node_count = 3

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
  node_count = 3

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

resource "google_compute_address" "app_ip" {
  name = "app-load-balancer-ip"
}

resource "google_compute_global_address" "global_ip" {
  name = "app-global-load-balancer-ip"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_manifest" "argocd_install" {
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = "argocd"
    }
  }
}

resource "kubernetes_manifest" "argocd_install_yaml" {
  manifest = {
    apiVersion = "v1"
    kind       = "List"
    items      = templatefile("https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml", {})
  }
  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_service" "app1_service" {
  metadata {
    name = "app1-service"
  }

  spec {
    selector = {
      app = "https://github.com/YoussefMobarak1702/app1"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "app2_service" {
  metadata {
    name = "app2-service"
  }

  spec {
    selector = {
      app = "https://github.com/YoussefMobarak1702/app1"
    }

    port {
      port        = 80
      target_port = 9090
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "load_balancer" {
  metadata {
    name = "app-ingress"
  }

  spec {
    rule {
      http {
        path {
          path      = "/app1"
          
          backend {
            service {
              name = "app1-service"
              port {
                number = 80
              }
              weight = 20
            }
          }
        }

        path {
          path      = "/app2"
          backend {
            service {
              name = "app2-service"
              port {
                number = 80
              }
              weight = 80
            }
          }
        }
      }
    }
  }
}