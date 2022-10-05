variable "settings" {
  description = "Customize a bit.."
  
  type = object({
    application_name        = optional(string, "nomad-csi")
    resource_group_name     = optional(string, "nomad-csi-demo")
    resource_group_location = optional(string, "NorwayEast")
  })
  
  default = {}
}
