#### Network Security Groups can be imported using the resource id.
`terraform import module.network_security_group.azurerm_network_security_group.security_group /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd/providers/Microsoft.Network/networkSecurityGroups/AZ-NSG-Infra-prd-Monitor`

#### Usage
```hcl
module "network_security_group" {
  depends_on           = [module.resource_group,module.virtual_network]
  source               = "git::https://github.com/goldstrike77/terraform-module-azure//network_security_grou?ref=v0.1"
  location             = var.location
  environment          = var.environment
  project              = var.project
  customer             = var.customer
  nsgr_name            = var.nsgr_name
  nsgr_priority        = var.nsgr_priority
  nsgr_direction       = var.nsgr_direction
  nsgr_access          = var.nsgr_access
  nsgr_prot            = var.nsgr_prot
  nsgr_sour_port       = var.nsgr_sour_port
  nsgr_dest_port       = var.nsgr_dest_port
  nsgr_sour_addr       = var.nsgr_sour_addr
  nsgr_dest_addr       = var.nsgr_dest_addr
  tag                  = var.tag
}
```