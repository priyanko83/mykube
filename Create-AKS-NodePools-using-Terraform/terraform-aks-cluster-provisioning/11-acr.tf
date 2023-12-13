resource "azurerm_container_registry" "acr" {
  name                     = "poc12378acr"
  resource_group_name      = azurerm_resource_group.aks_rg.name
  location                 = azurerm_resource_group.aks_rg.location
  sku                      = "Basic"
  admin_enabled            = false
}