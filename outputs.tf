output "frontend_url" {
  description = "URL for frontend application"
  value       = "http://localhost:${var.frontend_port}"
}

output "backend_url" {
  description = "URL for backend API"
  value       = "http://localhost:${var.backend_port}/api"
}
