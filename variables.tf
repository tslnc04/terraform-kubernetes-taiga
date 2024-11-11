variable "namespace" {
  description = "namespace to put taiga resources in"
  type        = string
  default     = "taiga"
}

variable "secret_path" {
  description = "path to the secret in 1Password"
  type        = string
}

variable "db_path" {
  description = "local path to the database volume"
  type        = string
}

variable "static_path" {
  description = "local path to the static volume"
  type        = string
}

variable "media_path" {
  description = "local path to the media volume"
  type        = string
}

variable "async_rabbitmq_path" {
  description = "local path to the async RabbitMQ volume"
  type        = string
}

variable "events_rabbitmq_path" {
  description = "local path to the events RabbitMQ volume"
  type        = string
}

variable "pv_prefix" {
  description = "prefix for taiga PVs, not including a trailing dash"
  type        = string
  default     = "taiga"
}

variable "pv_node" {
  description = "hostname of the node the PVs should be on"
  type        = string
}

variable "http_route" {
  description = "if specified, the data required to create an HTTP route for the taiga gateway service"
  type = object({
    hostnames = list(string)
    parent_gateway = object({
      name         = string
      namespace    = string
      section_name = string
    })
  })

  nullable = true
  default  = null

  validation {
    condition     = var.http_route == null ? true : length(var.http_route.hostnames) > 0
    error_message = "at least one hostname must be specified"
  }
}
