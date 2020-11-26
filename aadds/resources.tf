# 创建活动目录域服务。
resource "azurerm_template_deployment" "aadds" {
  name                = "aadds-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  parameters          = {
    apiVersion              = "2017-06-01"
    name                    = "aadds-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
    domainConfigurationType = lookup(var.aadds_spec, "type", "FullySynced")
    domainName              = lookup(var.aadds_spec, "domain", "partner.onmschina.cn")
    filteredSync            = "Disabled"
    location                = var.location
    subnetName              = "snet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-Aadds"
    vnetName                = "vnet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
    vnetResourceGroup       = "rg-${title(var.customer)}-${upper(var.env)}"
  }
  deployment_mode    = "Incremental"
  template_body      = <<DEPLOY
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "name": {
            "type": "string"
        },
        "apiVersion": {
            "type": "string"
        },
        "domainConfigurationType": {
            "type": "string"
        },
        "domainName": {
            "type": "string"
        },
        "filteredSync": {
            "type": "string"
        },
        "location": {
            "type": "string"
        },
        "subnetName": {
            "type": "string"
        },
        "vnetName": {
            "type": "string"
        },
        "vnetResourceGroup": {
            "type": "string"
        }
    },
    "resources": [
        {
            "apiVersion": "[parameters('apiVersion')]",
            "type": "Microsoft.AAD/DomainServices",
            "name": "[parameters('name')]",
            "location": "[parameters('location')]",
            "properties": {
                "domainName": "[parameters('domainName')]",
                "subnetId": "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', parameters('vnetResourceGroup'), '/providers/Microsoft.Network/virtualNetworks/', parameters('vnetName'), '/subnets/', parameters('subnetName'))]",
                "filteredSync": "[parameters('filteredSync')]",
                "ldapsSettings": {
                    "ldaps": "Enabled",
                    "pfxCertificate": "string",
                    "pfxCertificatePassword": "string",
                    "externalAccess": "Enabled"
                },
                "notificationSettings": {
                    "notifyGlobalAdmins": "Enabled",
                    "notifyDcAdmins": "Enabled",
                    "additionalRecipients": []
                }
            }
        }
    ],
    "outputs": {}
}
DEPLOY
}