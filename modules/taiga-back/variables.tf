variable "name" {
  description = "name of the back instance"
  type        = string
}

variable "namespace" {
  description = "namespace to put taiga resources in"
  type        = string
}

variable "secret" {
  description = "name of the secret containing the environment variables"
  type        = string
}

variable "config_map" {
  description = "name of the config map containing the environment variables"
  type        = string
}

variable "events_rabbitmq" {
  description = "domain of the events RabbitMQ service"
  type        = string
}

variable "async_rabbitmq" {
  description = "domain of the async RabbitMQ service"
  type        = string
}

variable "postgres" {
  description = "domain of the taiga PostgreSQL service"
  type        = string
}

variable "static_volume" {
  description = "name of the static PVC"
  type        = string
}

variable "media_volume" {
  description = "name of the media PVC"
  type        = string
}

variable "async" {
  description = "whether this is an async instance"
  type        = bool
  default     = false
}
