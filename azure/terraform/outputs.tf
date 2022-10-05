//////////////////////////////////
// Outputs
//////////////////////////////////

output "info" {
  sensitive = true
  
  value = {
    id     = azuread_application.MAIN.application_id
    secret = azuread_service_principal_password.MAIN.value
  }
}
