# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acrbasick8s${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = var.tags
}

# Random suffix for ACR name (must be globally unique)
resource "random_string" "acr_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Assign AcrPull role to AKS managed identity
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}
