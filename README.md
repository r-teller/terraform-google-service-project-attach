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
- Serverless VPC Access: (This is a duplciate entry for Cloud Function/Run snippets above)
  - https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#service_account_permissions
- Dataproc:
  - https://cloud.google.com/dataproc/docs/concepts/configuring-clusters/network#create_a_cluster_that_uses_a_network_in_another_project
- Dataflow:
  - https://cloud.google.com/dataflow/docs/guides/specifying-networks#shared
- Data Fusion:
  - https://cloud.google.com/data-fusion/docs/how-to/create-private-ip#set_up_iam_permissions  
- Vertex AI:
  - https://cloud.google.com/vertex-ai/docs/workbench/user-managed/service-perimeter#shared-vpc
- Cloud TPU:
  - https://cloud.google.com/tpu/docs/shared-vpc-networks
- Cloud Workstations: (Not Documented yet)
  - https://cloud.google.com/workstations/docs/architecture
  