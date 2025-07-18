<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../modules/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tgw_asn"></a> [tgw\_asn](#input\_tgw\_asn) | n/a | `number` | n/a | yes |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPCs to be created | <pre>map(object({<br/>    cidr = string,<br/>    type = string,<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
