
resource null_resource print_names {
  provisioner "local-exec" {
    command = "echo 'Resource group: ${var.resource_group_name}'"
  }
}

data "ibm_resource_group" "tools_resource_group" {
  depends_on = [null_resource.print_names]

  name = var.resource_group_name
}

locals {
  name_prefix = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  name        = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${var.label}"
  service     = "logdnaat"
}

resource ibm_resource_instance at_instance {
  count             = var.provision ? 1 : 0
  name              = local.name
  service           = local.service
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

data ibm_resource_instance instance {
  depends_on = [ibm_resource_instance.at_instance]

  name              = local.name
  resource_group_id = data.ibm_resource_group.tools_resource_group.id
  location          = var.resource_location
  service           = local.service
}
