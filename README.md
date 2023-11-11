# GCP Terraform Service Project Attach
Terraform to attach Service Projects to Host Project, grants IAM permissions to the default Service Accounts within the Service Project based on the enabled Cloud APIs. If one or more Cloud APIs is enabled/disabled, you can re-run terraform apply and this module will make the appropriate changes to IAM.

## Hierarchy
Example:
```
|---projects
    +---project-alpha-aaaa
    |       main.tf
    |       terraform.tf
    |       terraform.tfvars
    |       variables.tf
    |
    +---project-bravo-aaa
    |       main.tf
    |       terraform.tf
    |       terraform.tfvars
    |       variables.tf
    |
    \---project-charlie-aaa
            main.tf
            terraform.tf
            terraform.tfvars
            variables.tf
```

## Service Project Management
Shared VPC connects projects within the same organization. Participating host and service projects cannot belong to different organizations. Linked projects can be in the same or different folders, but if they are in different folders the admin must have Shared VPC Admin rights to both folders. Refer to the Google Cloud resource hierarchy for more information about organizations, folders, and projects.
- https://cloud.google.com/vpc/docs/shared-vpc


```
## terraform.tfvars
host_project_id     = "my-host-project"
service_project_id  = "your-service-project"
```

### Grant Service Projects IAM permissions without Service Project Attach
If you have already gone through the level of effort required to attach multiple service projects to one or more host projects you can set `attach_service_project = false` and this module will still handle granting the required IAM permissions without attaching the specified service project to the host project

```
## terraform.tfvars
host_project_id        = "my-host-project"
service_project_id     = "your-service-project"
attach_service_project = false
```

## Allowed Subnetworks
The allowed_subnetworks variable is used to determine if "roles/compute.networkUser" should be restricted to a specific set of subnetworks or all subnetworks should be allowed
  - if allowed_subnetworks = null then "roles/compute.networkUser" will have access to all subnetworks
  - if allowed_subnetworks = [] then "roles/compute.networkUser" will have access to no subnetworks
  - you may specify a list containing one or more subnetwork self_links to be allowed
  - allowed_subnetworks = [
      "https://www.googleapis.com/compute/v1/projects/example-project/regions/us-central1/subnetworks/first-subnetwork",
      "https://www.googleapis.com/compute/v1/projects/example-project/regions/us-central1/subnetworks/second-subnetwork",
    ]


## Elevated Permissions
### Grant Additional Users compute.networkUser role
This module supports providing compute.networkUser role to a list of users, serviceAccounts, groups or domains. If allowed_subnetworks is null these permissions are granted on the project level if allowed_subnetworks is not null permissions are granted on the subnetwork level

### Grant services compute.networkAdmin role
Most services are granted "roles/compute.networkUser" but some services need elevated permissions to function properly, in the past this module automatically granted those services the required permissions. Going forward a new variable (grant_services_network_admin_role) will be included and for a short interim set to true, at some point this may be changed to false. I recommend updating modules that require elevated permissions to explicitly call out true to prevent unexpected outages.

If grant_services_security_admin_role is set to true services that can use the elevated permissions will be granted the "roles/compute.networAdmin", https://cloud.google.com/compute/docs/access/iam#compute.networkAdmin

The following services are able to take advantage of "roles/compute.networAdmin"
- "composer.googleapis.com"
- "datastream.googleapis.com"
- "workstations.googleapis.com"

#### Grant service compute.securityAdmin role
Most services are granted "roles/compute.networkUser" but some services need elevated permissions to function properly, a new variable (grant_services_security_admin_role) has been added and by default is set to false, if set to true services that can use the elevated permissions will be granted the "role/compute.securityAdmin". https://cloud.google.com/compute/docs/access/iam#compute.securityAdmin

The following services are able to take advantage of "roles/compute.securityAdmin"
- "container.googleapis.com"

## Prerequisites
Terraform can be downloaded from HashiCorp's [site](https://www.terraform.io/downloads.html).
Alternatively you can use your system's package manager.

The Terraform version is defined in the `terraform` block in `terraform.tf`

`gcloud` can be installed using Google's [documentation](https://cloud.google.com/sdk/docs/install).

# Supported Google Products
All products listed below should be supported by this terraform module and automatically grant the appropriate permissions to attached services projects <b><i>based on enabled apis</i></b>. No additional IAM work should be required.
- Cloud Composer:
  - https://cloud.google.com/composer/docs/how-to/managing/configuring-shared-vpc#configure_the_host_project
- Google Kubernetes
  - Engine: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc#enabling_and_granting_roles
- Traffic Director:
  - https://cloud.google.com/architecture/configuring-traffic-director-with-shared-vpc-on-multiple-gke-clusters#configure_iam_roles
- Cloud Functions: 
  - https://cloud.google.com/functions/docs/networking/shared-vpc-host-project#provide_access_to_the_connector
  - https://cloud.google.com/functions/docs/networking/shared-vpc-service-projects#grant-permissions
- Cloud Run:
  - https://cloud.google.com/run/docs/configuring/shared-vpc-host-project#provide_access_to_the_connector
  - https://cloud.google.com/run/docs/configuring/shared-vpc-service-projects#grant-permissions
- Serverless VPC Access: (This is a duplicate entry for Cloud Function/Run snippets above)
  - https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#service_account_permissions
- Dataproc:
  - https://cloud.google.com/dataproc/docs/concepts/configuring-clusters/network#create_a_cluster_that_uses_a_network_in_another_project
- Dataflow:
  - https://cloud.google.com/dataflow/docs/guides/specifying-networks#shared
- Data Fusion:
  - https://cloud.google.com/data-fusion/docs/how-to/create-private-ip#set_up_iam_permissions  
- Datastream:
  - https://cloud.google.com/datastream/docs/create-a-private-connectivity-configuration
- Vertex AI:
  - https://cloud.google.com/vertex-ai/docs/workbench/user-managed/service-perimeter#shared-vpc
- Cloud TPU:
  - https://cloud.google.com/tpu/docs/shared-vpc-networks
- Cloud Workstations:
  - https://cloud.google.com/workstations/docs/architecture
  - https://cloud.google.com/workstations/docs/access-control#workstations-network-admin
  