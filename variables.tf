variable "host_project_id" {
  description = "Host project_id that the service project will be attached to"
  type        = string
}

variable "service_project_id" {
  description = "Service project_id that the will be attached to a host project"
  type        = string
}

variable "attach_service_project" {
  description = "Specifies if the service project should be attached to the host project. If the service project is already attached and this module is just used to grant permissions then this should be set to false"
  type        = bool
  default     = true
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

variable "additional_network_user_members" {
  type    = list(string)
  default = []

  validation {
    condition = alltrue([
      for additional_network_user_member in var.additional_network_user_members : can(regex("^((serviceAccount:)|(user:)|(domain:)|(group:)).*$", additional_network_user_member))
    ])
    error_message = "Strings in var.additional_network_user_members must start with one of the following values [serviceAccount, user, domain or group]"
  }
}
