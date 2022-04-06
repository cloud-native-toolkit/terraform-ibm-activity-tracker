
resource null_resource print_names {
  provisioner "local-exec" {
    command = "echo 'Resource group: ${var.resource_group_name}'"
  }
}

data ibm_resource_group resource_group {
  depends_on = [null_resource.print_names]

  name = var.resource_group_name
}

module "clis" {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource "random_uuid" "tag" {
}

locals {
  name        = "activity-tracker-${var.resource_location}"
  service     = "logdnaat"
  service_catalog_id = "dcc46a60-e13b-11e8-a015-757410dab16b"
}

resource null_resource at_instance {
  depends_on = [null_resource.print_names, module.clis]

  triggers = {
    INSTANCE_NAME = local.name
    SERVICE = local.service
    ACTIVITY_TRACKER_CATALOG_ID = local.service_catalog_id
    IBMCLOUD_API_KEY = base64encode(var.ibmcloud_api_key)
    RESOURCE_GROUP_ID  = data.ibm_resource_group.resource_group.id
    AUTOMATION_TAG  = "automation:${random_uuid.tag.result}"
    BIN_DIR = module.clis.bin_dir
  }

  provisioner "local-exec" {
    when        = create
    command = "${path.module}/scripts/create-resource-group.sh"
    environment = {
      INSTANCE_NAME = self.triggers.INSTANCE_NAME
      SERVICE = self.triggers.SERVICE
      ACTIVITY_TRACKER_CATALOG_ID = self.triggers.ACTIVITY_TRACKER_CATALOG_ID
      IBMCLOUD_API_KEY = base64decode(self.triggers.IBMCLOUD_API_KEY)
      RESOURCE_GROUP_ID  = self.triggers.RESOURCE_GROUP_ID
      AUTOMATION_TAG  = self.triggers.AUTOMATION_TAG
      BIN_DIR = self.triggers.BIN_DIR
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command = "${path.module}/scripts/delete-resource-group.sh"
    environment = {
      INSTANCE_NAME = self.triggers.INSTANCE_NAME
      SERVICE = self.triggers.SERVICE
      ACTIVITY_TRACKER_CATALOG_ID = self.triggers.ACTIVITY_TRACKER_CATALOG_ID
      IBMCLOUD_API_KEY = base64decode(self.triggers.IBMCLOUD_API_KEY)
      RESOURCE_GROUP_ID  = self.triggers.RESOURCE_GROUP_ID
      AUTOMATION_TAG  = self.triggers.AUTOMATION_TAG
      BIN_DIR = self.triggers.BIN_DIR
    }
  }
}


data ibm_resource_instance instance {
  depends_on = [ibm_resource_instance.at_instance]

  resource_group_id = data.ibm_resource_group.resource_group.id
  location          = var.resource_location
  service           = local.service
}
