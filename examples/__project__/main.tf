module "service_project_attach" {
  source  = "r-teller/service-project-attach/google"
  version = ">=0.0.0"


  host_project_id    = var.host_project_id
  service_project_id = var.service_project_id

  ## The allowed_subnetworks variable is used to determine if "roles/compute.networkUser" should be restricted to a specific set of subnets or all subnets
  # if allowed_subnetworks = null then "roles/compute.networkUser" will have access to all subnets
  # if allowed_subnetworks = [] then "roles/compute.networkUser" will have access to no subnets
  # you may specify a list containing one or more subnet self_links to be allowed
  # allowed_subnetworks = [
  #   "https://www.googleapis.com/compute/v1/projects/example-project/regions/us-central1/subnetworks/first-subnetwork",
  #   "https://www.googleapis.com/compute/v1/projects/example-project/regions/us-central1/subnetworks/second-subnetwork",
  # ]
  allowed_subnetworks = null

  ## Grants role/compute.securityAdmin permission to services that can use it 
  grant_services_security_admin_role = true

  ## Grants role/compute.networkAdmin permission to services that can use it 
  grant_services_network_admin_role = true

  additional_network_user_members = []
}
