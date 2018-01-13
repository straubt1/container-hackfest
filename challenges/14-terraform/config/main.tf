provider "kubernetes" {}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "${var.namespace_name}"
  }
}

resource "kubernetes_pod" "demo" {
  metadata {
    name = "terraform-example"

    labels {
      app = "MyApp"
    }
  }

  spec {
    container {
      image = "evillgenius/kuar:1"
      name  = "my-ctr"

      port = {
        container_port = 8080
      }
    }
  }
}

resource "kubernetes_service" "demo" {
  metadata {
    name      = "my-healthysvc"
    namespace = "${var.namespace_name}"
  }

  spec {
    selector {
      app = "${kubernetes_pod.demo.metadata.0.labels.app}"
    }
    session_affinity = "ClientIP"
    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}