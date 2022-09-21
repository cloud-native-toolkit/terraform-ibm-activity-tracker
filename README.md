
# IBM Activity Tracker module

Provisions the IBM Cloud hosted Activity Tracker service



## Software dependencies

The module depends on the following software components:

### Terraform version

- \>= v0.15

### Terraform providers

- ibm (ibm-cloud/ibm)
- clis (cloud-native-toolkit/clis)

### Module dependencies

- resource_group - [github.com/cloud-native-toolkit/terraform-ibm-resource-group](https://github.com/cloud-native-toolkit/terraform-ibm-resource-group) (>= 2.1.0)
- sync - interface github.com/cloud-native-toolkit/automation-modules#sync

## Example usage

[Refer to examples for more details](test/stages)

```
module "ibm-activity-tracker" {
  source = "cloud-native-toolkit/activity-tracker/ibm"


  ibmcloud_api_key = var.ibmcloud_api_key
  plan = var.ibm-activity-tracker_plan
  resource_group_name = module.resource_group.name
  resource_location = var.region
  sync = var.ibm-activity-tracker_sync
  tags = var.ibm-activity-tracker_tags == null ? null : jsondecode(var.ibm-activity-tracker_tags)
}
```

## Module details

### Inputs

| Name | Description | Required | Default | Source |
|------|-------------|---------|----------|--------|
| ibmcloud_api_key | The IBM Cloud api key | true |  |  |
| resource_group_name | Resource group where the cluster has been provisioned. | true |  | resource_group.name |
| resource_location | Geographic location of the resource (e.g. us-south, us-east) | true |  |  |
| tags | Tags that should be applied to the service |  |  |  |
| plan | The type of plan the service instance should run under (lite, 7-day, 14-day, or 30-day) |  | 7-day |  |
| sync | Value used to order the provisioning of the instance | true |  | sync.sync |


### Outputs

| Name | Description |
|------|-------------|
| id | The id of the provisioned instance. |
| guid | The id of the provisioned instance. |
| name | The name of the provisioned instance. |
| crn | The id of the provisioned instance |
| location | The location of the provisioned instance |
| service | The service name of the key provisioned for the instance |
| label | The label for the instance |
| sync | Value used to order the provisioning of the instance |


## Resources

- [Documentation](https://operate.cloudnativetoolkit.dev)
- [Module catalog](https://modules.cloudnativetoolkit.dev)

> License: Apache License 2.0 | Generated by iascable (2.19.1)
