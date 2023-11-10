data "google_project" "service_project" {
  project_id = var.service_project_id
}

data "google_compute_default_service_account" "compute_default_service_account" {
  project = var.service_project_id
}

data "google_iam_testable_permissions" "cloudresourcemanager" {
  full_resource_name = "//cloudresourcemanager.googleapis.com/projects/${var.service_project_id}"
  stages             = ["GA", "BETA"]
}

locals {
  enabled_resources = distinct(flatten([for api in data.google_iam_testable_permissions.cloudresourcemanager.permissions : [
    "${split(".", api.name)[0]}"
    ]
  if api.api_disabled == false && split(".", api.name)[2] == "create"]))

  compute_default_service_account = data.google_compute_default_service_account.compute_default_service_account.email != null ? data.google_compute_default_service_account.compute_default_service_account.email : "${data.google_project.service_project.number}-compute@developer.gserviceaccount.com"
  iam_role_list = {
    "container.googleapis.com" = { #<-- Required for Kubernetes Engine API
      "roles/compute.networkUser" = [
        "serviceAccount:service-${data.google_project.service_project.number}@container-engine-robot.iam.gserviceaccount.com",
      ],
      "roles/container.hostServiceAgentUser" = [
        "serviceAccount:service-${data.google_project.service_project.number}@container-engine-robot.iam.gserviceaccount.com",
      ]
      "roles/compute.securityAdmin" = (var.grant_services_security_admin_role ?
        [
          "serviceAccount:service-${data.google_project.service_project.number}@container-engine-robot.iam.gserviceaccount.com",
        ] : []
      )
    },
    "compute.googleapis.com" = { #<-- Required for Compute Engine API
      "roles/compute.networkUser" = [
        "serviceAccount:${local.compute_default_service_account}"
      ]
    },
    "cloudfunctions.googleapis.com" = { #<-- Required for Cloud Functions API
      "roles/vpcaccess.user" = [
        "serviceAccount:service-${data.google_project.service_project.number}@gcf-admin-robot.iam.gserviceaccount.com",
      ],
    },
    "run.googleapis.com" = { #<-- Required for Cloud Run Admin API
      "roles/vpcaccess.user" = [
        "serviceAccount:service-${data.google_project.service_project.number}@serverless-robot-prod.iam.gserviceaccount.com",
      ],
    },
    "tpu.googleapis.com" = { #<-- Required for Cloud TPU API
      "roles/tpu.xpnAgent" = [
        "serviceAccount:service-${data.google_project.service_project.number}@gcp-sa-tpu.iam.gserviceaccount.com",
      ],
    },
    "composer.googleapis.com" = { #<-- Required for Cloud Composer API
      "roles/compute.networkAdmin" = (var.grant_services_network_admin_role ?
        [
          "serviceAccount:service-${data.google_project.service_project.number}@cloudcomposer-accounts.iam.gserviceaccount.com",
        ] : []
      )
      "roles/composer.sharedVpcAgent" = [
        "serviceAccount:service-${data.google_project.service_project.number}@cloudcomposer-accounts.iam.gserviceaccount.com",
      ],
    },
    "dataproc.googleapis.com" = { #<-- Required for Dataproc API
      "roles/compute.networkUser" = [
        "serviceAccount:service-${data.google_project.service_project.number}@dataproc-accounts.iam.gserviceaccount.com",
      ]
    },
    "dataflow.googleapis.com" = { #<-- Required for Dataflow API
      "roles/compute.networkUser" = [
        "serviceAccount:service-${data.google_project.service_project.number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
      ]
    },
    "datafusion.googleapis.com" = { #<-- Required for Data Fusion API
      "roles/compute.networkUser" = [
        "serviceAccount:service-${data.google_project.service_project.number}@gcp-sa-datafusion.iam.gserviceaccount.com",
      ]
    },
    "datastream.googleapis.com" = { #<-- Required for Datastream API
      "roles/compute.networkAdmin" = (var.grant_services_network_admin_role ?
        [
          "serviceAccount:service-${data.google_project.service_project.number}@gcp-sa-datastream.iam.gserviceaccount.com",
        ] : []
      )
    },
    "vpcaccess.googleapis.com" = { #<-- Required for Serverless VPC-Access API
      "roles/compute.networkUser" = [
        "serviceAccount:service-${data.google_project.service_project.number}@gcp-sa-vpcaccess.iam.gserviceaccount.com",
      ]
    },
    "notebooks.googleapis.com" = { #<-- Required for Vertex AI API
      "roles/compute.networkUser" = [
        "serviceAccount:service-${data.google_project.service_project.number}@gcp-sa-notebooks.iam.gserviceaccount.com",
      ]
    },
    "workstations.googleapis.com" = { #<-- Required for Cloud Workstation API
      "roles/workstations.networkAdmin" = (var.grant_services_network_admin_role ?
        [
          "serviceAccount:service-${data.google_project.service_project.number}@gcp-sa-workstations.iam.gserviceaccount.com",
        ] : []
      )
    }
  }

  subnetwork_mappings = var.allowed_subnetworks != null ? { for subnetwork in var.allowed_subnetworks : subnetwork => regex("regions/(?P<region>[^/]*)/subnetworks/(?P<subnetwork>[^/]*)$", subnetwork) } : null

  iam_role_mappings = flatten([
    for service in keys(local.iam_role_list) : [
      for role in keys(local.iam_role_list[service]) : [
        for member in local.iam_role_list[service][role] : [
          {
            service = service
            enabled = contains(local.enabled_resources, split(".", service)[0])
            role    = role
            member  = member
            key     = join("_", [role, member])
            subnets = (
              local.subnetwork_mappings != null
              &&
              role == "roles/compute.networkUser"
            ) ? local.subnetwork_mappings : null
          }
        ] if contains(local.enabled_resources, split(".", service)[0])
      ]
    ]
  ])
}

resource "google_compute_shared_vpc_service_project" "service_project_attach" {
  count           = var.attach_service_project ? 1 : 0
  host_project    = var.host_project_id
  service_project = var.service_project_id
}


### Grants access at the project level to all subnetworks if allowed_subnetworks is null
resource "google_project_iam_member" "cloudservices" {
  count   = local.subnetwork_mappings == null ? 1 : 0
  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${data.google_project.service_project.number}@cloudservices.gserviceaccount.com"
}

resource "google_project_iam_member" "additional_network_user_members" {
  for_each = { for additional_network_user_member in var.additional_network_user_members : additional_network_user_member => {} if var.allowed_subnetworks == null }
  project  = var.host_project_id
  role     = "roles/compute.networkUser"
  member   = each.key
}

resource "google_project_iam_member" "iam_member" {
  for_each = { for iam in local.iam_role_mappings : iam.key => iam if iam.subnets == null }

  project = var.host_project_id
  role    = each.value.role
  member  = each.value.member
}

### Grants access at the subnetwork level based on the list of allowed_subnetworks
resource "google_compute_subnetwork_iam_member" "cloudservices" {
  for_each = local.subnetwork_mappings != null ? local.subnetwork_mappings : {}

  project    = var.host_project_id
  region     = each.value.region
  subnetwork = each.value.subnetwork
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${data.google_project.service_project.number}@cloudservices.gserviceaccount.com"
}

resource "google_compute_subnetwork_iam_member" "additional_network_user_members" {
  for_each = merge([for additional_network_user_member in var.additional_network_user_members : { for subnetwork, attributes in local.subnetwork_mappings : format("%s-%s", additional_network_user_member, subnetwork) => merge({ member = additional_network_user_member }, attributes) } if local.subnetwork_mappings != null]...)

  project    = var.host_project_id
  region     = each.value.region
  subnetwork = each.value.subnetwork
  role       = "roles/compute.networkUser"
  member     = each.value.member
}

resource "google_compute_subnetwork_iam_member" "iam_member" {
  for_each = merge([for iam in local.iam_role_mappings : { for subnet, attributes in iam.subnets : format("%s-%s", iam.key, subnet) => merge({ member = iam.member }, attributes) } if iam.subnets != null]...)

  project    = var.host_project_id
  region     = each.value.region
  subnetwork = each.value.subnetwork
  role       = "roles/compute.networkUser"
  member     = each.value.member
}
