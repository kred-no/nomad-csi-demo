//////////////////////////////////
// Outputs
//////////////////////////////////

output "info" {
  sensitive = true
  
  value = {
    app_id   = azuread_application.MAIN.application_id
    secret   = azuread_service_principal_password.MAIN.value
    rg_name  = azurerm_resource_group.MAIN.name
    location = azurerm_resource_group.MAIN.location
  }
}
