variable "namespace" {
  description = "namespace to put taiga resources in"
  type        = string
}

variable "front_domain" {
  description = "domain for the front instance"
  type        = string
}

variable "back_domain" {
  description = "domain for the back instance"
  type        = string
}

variable "events_domain" {
  description = "domain for the events instance"
  type        = string
}

variable "protected_domain" {
  description = "domain for the protected instance"
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
    condition     = var.http_route == null || length(var.http_route.hostnames) > 0
    error_message = "at least one hostname must be specified"
  }
}
