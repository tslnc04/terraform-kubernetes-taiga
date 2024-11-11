variable "namespace" {
  description = "namespace to put taiga resources in"
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

variable "static_path" {
  description = "local path for taiga back static volume"
  type        = string
}

variable "media_path" {
  description = "local path for taiga back media volume"
  type        = string
}
