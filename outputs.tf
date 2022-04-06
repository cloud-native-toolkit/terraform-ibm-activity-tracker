output "id" {
  value       = data.ibm_resource_instance.instance.id
  description = "The id of the provisioned instance."
}

output "guid" {
  value       = data.ibm_resource_instance.instance.guid
  description = "The id of the provisioned instance."
}

output "name" {
  value       = local.name
  depends_on  = [null_resource.at_instance]
  description = "The name of the provisioned instance."
}

output "crn" {
  description = "The id of the provisioned instance"
  value       = data.ibm_resource_instance.instance.id
}

output "location" {
  description = "The location of the provisioned instance"
  value       = var.resource_location
  depends_on  = [data.ibm_resource_instance.instance]
}

output "service" {
  description = "The service name of the key provisioned for the instance"
  value       = local.service
  depends_on = [data.ibm_resource_instance.instance]
}

output "label" {
  description = "The label for the instance"
  value       = var.resource_location
  depends_on = [data.ibm_resource_instance.instance]
}
