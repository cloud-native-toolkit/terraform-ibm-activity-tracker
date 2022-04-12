module "dev_activity_tracker" {
  source = "./module"

  resource_group_name      = module.resource_group.name
  resource_location        = "eu-gb"
  ibmcloud_api_key         = var.ibmcloud_api_key
}

# test to handle parallel execution
module "dev_activity_tracker2" {
  source = "./module"

  resource_group_name      = module.resource_group.name
  resource_location        = "eu-gb"
  ibmcloud_api_key         = var.ibmcloud_api_key
}
