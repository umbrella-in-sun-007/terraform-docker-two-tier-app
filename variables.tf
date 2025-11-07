variable "frontend_port" {
  description = "External port for frontend container"
  type        = number
  default     = 8080
}

variable "backend_port" {
  description = "External port for backend container"
  type        = number
  default     = 5000
}
