provider "ibm" {
  version = ">= 1.2.1"
}

data "ibm_resource_group" "tools_resource_group" {
  name = var.resource_group_name
}

locals {
  role            = "Manager"
  name_prefix     = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
}

resource "ibm_resource_instance" "at_instance" {
  count             = var.provision ? 1 : 0
  name              = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-activity-tracker"
  service           = "logdnaat"
  plan              = var.plan
  location          = var.resource_location
  resource_group_id = data.ibm_resource_group.tools_resource_group.id
  tags              = var.tags

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}
