terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# --------------------------
# Docker Network
# --------------------------
resource "docker_network" "app_network" {
  name = "terraform_app_network"
}

# --------------------------
# Backend Image & Container
# --------------------------
resource "docker_image" "backend_image" {
  name = "flask-backend:latest"
  build {
    context = "${path.module}/backend"
  }
}

resource "docker_container" "backend" {
  name  = "flask-backend"
  image = docker_image.backend_image.image_id   # fixed here
  networks_advanced {
    name = docker_network.app_network.name
  }
  ports {
    internal = 5000
    external = var.backend_port
  }
}

# --------------------------
# Frontend Image & Container
# --------------------------
resource "docker_image" "frontend_image" {
  name = "nginx-frontend:latest"
  build {
    context = "${path.module}/frontend"
  }
}

resource "docker_container" "frontend" {
  name  = "nginx-frontend"
  image = docker_image.frontend_image.image_id  # fixed here
  networks_advanced {
    name = docker_network.app_network.name
  }
  ports {
    internal = 80
    external = var.frontend_port
  }
  depends_on = [docker_container.backend]
}
