variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-basick8s"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-basick8s"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "basick8s"
}

variable "aks_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "frontdoor_name" {
  description = "Name of the Azure Front Door"
  type        = string
  default     = "afd-basick8s"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for the AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "Basick8s"
    ManagedBy   = "Terraform"
  }
}
