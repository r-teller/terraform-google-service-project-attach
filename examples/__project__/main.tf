module "service-project-attach" {
  source  = "r-teller/service-project-attach/google"
  version = ">=0.0.0"

  host_project_id    = var.host_project_id
  service_project_id = var.service_project_id
}

