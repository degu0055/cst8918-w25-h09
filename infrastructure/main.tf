terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-cluster-xyz"
  location = "Canada Central"
}

resource "azurerm_kubernetes_cluster" "app" {
  name                = "aks-cluster-xyz"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksclusterxyz"

  default_node_pool {
    name       = "default"
    node_count = 1         # fixed 1 node for system pool
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "autoscale_pool" {
  name                  = "autoscale"  # 9 characters, valid
  kubernetes_cluster_id = azurerm_kubernetes_cluster.app.id
  vm_size               = "Standard_B2s"
  node_count            = 1
  min_count             = 1
  max_count             = 3
  enable_auto_scaling   = true
  mode                  = "User"
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.app.kube_config_raw
  sensitive = true
}
