# Azure Front Door Profile (v2)
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = var.frontdoor_name
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "ep-${var.frontdoor_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  tags                     = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Origin Group (pointing to AKS)
resource "azurerm_cdn_frontdoor_origin_group" "aks" {
  name                     = "og-aks"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }

  health_probe {
    protocol            = "Http"
    path                = "/"
    request_type        = "HEAD"
    interval_in_seconds = 100
  }

  lifecycle {
    ignore_changes = all
  }
}

# Origin (AKS Public IP)
resource "azurerm_cdn_frontdoor_origin" "aks" {
  name                          = "origin-aks"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.aks.id
  enabled                       = true
  certificate_name_check_enabled = true

  host_name          = azurerm_public_ip.aks_ingress.ip_address
  http_port          = 80
  https_port         = 443
  origin_host_header = azurerm_public_ip.aks_ingress.ip_address
  priority           = 1
  weight             = 1000

  lifecycle {
    ignore_changes = all
  }
}

# Front Door Route
resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "route-default"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.aks.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.aks.id]
  
  enabled                = true
  forwarding_protocol    = "HttpOnly"
  https_redirect_enabled = false
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  link_to_default_domain = true

  lifecycle {
    ignore_changes = all
  }
}
