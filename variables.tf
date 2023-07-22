variable "host_project_id" {
  description = "Host project_id that the service project will be attached to"
  type        = string
}

variable "service_project_id" {
  description = "Service project_id that the will be attached to a host project"
  type        = string
}

## Not currently used but may be introduced in the future
# variable "grant_services_loadbalancer_admin_role" {
#   type    = bool
#   default = false
# }

## This is currently set to true to be non-breaking but at somepoint will default to false
variable "grant_services_network_admin_role" {
  description = "If set to true, services that can take advantage of compute.networkAdmin will be granted this role"
  type        = bool
  default     = true
}


variable "grant_services_security_admin_role" {
  description = "If set to true, services that can take advantage of compute.securityAdmin will be granted this role"
  type        = bool
  default     = false
}

variable "allowed_subnetworks" {
  description = "If this variable is set to something other than null only the list of specified subnetworks will be granted to this service project"
  type        = list(string)
  default     = null
}
