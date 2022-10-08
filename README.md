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