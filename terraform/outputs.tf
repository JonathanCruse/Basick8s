output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_kubeconfig" {
  description = "Kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "aks_public_ip" {
  description = "Public IP address for AKS ingress"
  value       = azurerm_public_ip.aks_ingress.ip_address
}

output "frontdoor_endpoint_hostname" {
  description = "Front Door endpoint hostname"
  value       = azurerm_cdn_frontdoor_endpoint.main.host_name
}

output "frontdoor_profile_id" {
  description = "Front Door profile ID"
  value       = azurerm_cdn_frontdoor_profile.main.id
}

output "get_aks_credentials_command" {
  description = "Command to get AKS credentials"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "Azure Container Registry name"
  value       = azurerm_container_registry.main.name
}

output "acr_login_command" {
  description = "Command to login to Azure Container Registry"
  value       = "az acr login --name ${azurerm_container_registry.main.name}"
}
