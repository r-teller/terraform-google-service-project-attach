locals {
    service_projects = [
        "rteller-demo-svc-aaaa",
        "rteller-demo-svc-bbbb",
        "rteller-demo-svc-cccc",

    ]
}


module "firewall_rules" { 
    source  = "r-teller/service-project-attach/google"

    project_id      = var.project_id
    network         = var.network

    for_each        = { for rule in local.firewall_rules:  "${rule.fileName}--${rule.id}" => rule }
    firewall_rule  = each.value
}
