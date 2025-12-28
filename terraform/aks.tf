# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.aks_dns_prefix
  tags                = var.tags

  default_node_pool {
    name           = "default"
    node_count     = var.aks_node_count
    vm_size        = var.aks_node_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }
}

# Public IP for AKS Ingress (will be used by Front Door)
resource "azurerm_public_ip" "aks_ingress" {
  name                = "pip-${var.aks_cluster_name}-ingress"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_kubernetes_cluster.main.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
