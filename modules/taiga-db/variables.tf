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

variable "volume_path" {
  description = "local path for this database instance's volume"
  type        = string
}

variable "pv_prefix" {
  description = "prefix for taiga PVs, not including a trailing dash"
  type        = string
}

variable "pv_node" {
  description = "hostname of the node the PV should be on"
  type        = string
}

variable "storage_class" {
  description = "name of the storage class to use for the PV"
  type        = string
  default     = "local-storage"
}
