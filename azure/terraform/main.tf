locals {
  application_name        = var.settings.application_name
  resource_group_name     = var.settings.resource_group_name
  resource_group_location = var.settings.resource_group_location
}

data "azuread_client_config" "CURRENT" {}

//////////////////////////////////
// AzureAD Resources
//////////////////////////////////

resource "azuread_application" "MAIN" {
  display_name = local.application_name
  owners       = [data.azuread_client_config.CURRENT.object_id]
}

resource "azuread_service_principal" "MAIN" {
  application_id               = azuread_application.MAIN.application_id
  app_role_assignment_required = true
  owners                       = [data.azuread_client_config.CURRENT.object_id]
}

resource "azuread_service_principal_password" "MAIN" {
  service_principal_id = azuread_service_principal.MAIN.object_id
}

//////////////////////////////////
// AzureRM Resources
//////////////////////////////////

resource "azurerm_resource_group" "MAIN" {
  name     = local.resource_group_name
  location = local.resource_group_location
}

resource "azurerm_role_assignment" "MAIN" {
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.MAIN.id
  principal_id         = azuread_service_principal.MAIN.object_id
}
