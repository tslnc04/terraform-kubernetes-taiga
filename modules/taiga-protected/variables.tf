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