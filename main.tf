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
      "roles/compute.networkAdmin" = [
        "serviceAccount:service-${data.google_project.service_project.number}@cloudcomposer-accounts.iam.gserviceaccount.com",
      ],
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
    "workstations.googleapis.com" = {
      "roles/workstations.networkAdmin" = [
        "serviceAccount:service-${data.google_project.service_project.number}@gcp-sa-workstations.iam.gserviceaccount.com"
      ],
    }
  }

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
          }
        ] if contains(local.enabled_resources, split(".", service)[0])
      ]
    ]
  ])
}

resource "google_compute_shared_vpc_service_project" "service_project_attach" {
  host_project    = var.host_project_id
  service_project = var.service_project_id
}

resource "google_project_iam_member" "cloudservices" {
  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${data.google_project.service_project.number}@cloudservices.gserviceaccount.com"
}

resource "google_project_iam_member" "iam_member" {
  for_each = { for iam in local.iam_role_mappings : iam.key => iam }

  project = var.host_project_id
  role    = each.value.role
  member  = each.value.member
}
