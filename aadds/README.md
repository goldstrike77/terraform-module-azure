#### Requirements
- [Grant Azure Active Directory permissions for Service Principal.](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration)
- [Create required Azure AD resources.](https://docs.microsoft.com/en-us/azure/active-directory-domain-services/template-create-instance)

#### Usage
```hcl
module "aadds" {
  depends_on = [module.subnet]
  source     = "/home/suzhetao/terraform/terraform-module-azure/aadds"
  location   = var.location
  env        = var.env
  customer   = var.customer
  aadds_spec = var.aadds_spec
}
```