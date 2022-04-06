variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api key"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where the cluster has been provisioned."
}

variable "resource_location" {
  type        = string
  description = "Geographic location of the resource (e.g. us-south, us-east)"
}

variable "tags" {
  type        = list(string)
  description = "Tags that should be applied to the service"
  default     = []
}

variable "plan" {
  type        = string
  description = "The type of plan the service instance should run under (lite, 7-day, 14-day, or 30-day)"
  default     = "7-day"
}

