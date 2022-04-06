
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
    command = "${path.module}/scripts/create-activity-tracker.sh"
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
    command = "${path.module}/scripts/delete-activity-tracker.sh"
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



data "local_file" "at_instance_results" {
  depends_on = [null_resource.at_instance]
  filename = "creation-output.json"
}

resource null_resource print_found {
  provisioner "local-exec" {
    command = "echo 'AT instance found: ${data.local_file.at_instance_results.content}'"
  }
}

data ibm_resource_instance instance {
  depends_on = [null_resource.at_instance, data.local_file.at_instance_results]

  name              = jsondecode(data.local_file.at_instance_results.content).name
  resource_group_id = jsondecode(data.local_file.at_instance_results.content).resource_group_id
  location          = jsondecode(data.local_file.at_instance_results.content).region_id
  service           = local.service
}
