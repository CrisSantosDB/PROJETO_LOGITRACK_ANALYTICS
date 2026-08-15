terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-logitrack-dev-brazilsouth"
    storage_account_name = "stlogitrackdevbrazsouth"
    container_name       = "tfstate"
    key                  = "logitrack.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "res-0" {
  location = "brazilsouth"
  name     = "rg-logitrack-dev-brazilsouth"
  tags = {
    Environment = "dev"
    Owner       = "data-engineering"
    Project     = "logitrack-analytics"
  }
}
resource "azurerm_iothub" "res-1" {
  location            = "brazilsouth"
  min_tls_version     = "1.2"
  name                = "iot-logitrack-dev"
  resource_group_name = "rg-logitrack-dev-brazilsouth"
  tags = {
    Environment = "dev"
    Owner       = "data-engineering"
    Project     = "logitrack-analytics"
  }

  sku {
    capacity = 1
    name     = "B1"
  }

  lifecycle {
    ignore_changes = [
      event_hub_partition_count,
      event_hub_retention_in_days,
      file_upload
    ]
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_kusto_cluster" "res-2" {
  location                    = "brazilsouth"
  name                        = "cl-logitrack-dev"
  resource_group_name         = "rg-logitrack-dev-brazilsouth"
  streaming_ingestion_enabled = true
  tags = {
    Environment = "dev"
    Owner       = "data-engineering"
    Project     = "logitrack-analytics"
  }
  identity {
    type = "SystemAssigned"
  }
  sku {
    name = "Dev(No SLA)_Standard_E2a_v4"
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_storage_account" "res-3" {
  account_replication_type         = "LRS"
  account_tier                     = "Standard"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  is_hns_enabled                   = true
  location                         = "brazilsouth"
  name                             = "stlogitrackdevbrazsouth"
  resource_group_name              = "rg-logitrack-dev-brazilsouth"
  tags = {
    Environment = "dev"
    Owner       = "data-engineering"
    Project     = "logitrack-analytics"
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_storage_container" "res-5" {
  name               = "telemetria"
  storage_account_id = azurerm_storage_account.res-3.id
}
resource "azurerm_synapse_workspace" "res-9" {
  location                             = "brazilsouth"
  name                                 = "syn-logitrack-dev-brs"
  resource_group_name                  = "rg-logitrack-dev-brazilsouth"
  sql_administrator_login              = "sqladminuser"
  storage_data_lake_gen2_filesystem_id = "https://stlogitrackdevbrazsouth.dfs.core.windows.net/telemetria"
  tags = {
    Environment = "dev"
    Owner       = "data-engineering"
    Project     = "logitrack-analytics"
  }
  identity {
    type = "SystemAssigned"
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_synapse_spark_pool" "res-12" {
  cache_size           = 50
  name                 = "sparkdev"
  node_size            = "Small"
  node_size_family     = "MemoryOptimized"
  spark_version        = "3.5"
  synapse_workspace_id = "/subscriptions/47aefbfa-9a52-4276-a127-e56c0172c292/resourceGroups/rg-logitrack-dev-brazilsouth/providers/Microsoft.Synapse/workspaces/syn-logitrack-dev-brs"
  tags = {
    " environment" = "dev"
  }
  auto_pause {
    delay_in_minutes = 5
  }
  auto_scale {
    max_node_count = 3
    min_node_count = 3
  }
  depends_on = [
    azurerm_synapse_workspace.res-9,
  ]
}
resource "azurerm_synapse_workspace_extended_auditing_policy" "res-14" {
  log_monitoring_enabled = false
  synapse_workspace_id   = "/subscriptions/47aefbfa-9a52-4276-a127-e56c0172c292/resourceGroups/rg-logitrack-dev-brazilsouth/providers/Microsoft.Synapse/workspaces/syn-logitrack-dev-brs"
  depends_on = [
    azurerm_synapse_workspace.res-9,
  ]
}
resource "azurerm_synapse_firewall_rule" "res-15" {
  end_ip_address       = "255.255.255.255"
  name                 = "allowAll"
  start_ip_address     = "0.0.0.0"
  synapse_workspace_id = "/subscriptions/47aefbfa-9a52-4276-a127-e56c0172c292/resourceGroups/rg-logitrack-dev-brazilsouth/providers/Microsoft.Synapse/workspaces/syn-logitrack-dev-brs"
  depends_on = [
    azurerm_synapse_workspace.res-9,
  ]
}
resource "azurerm_synapse_integration_runtime_azure" "res-16" {
  location             = "AutoResolve"
  name                 = "AutoResolveIntegrationRuntime"
  synapse_workspace_id = "/subscriptions/47aefbfa-9a52-4276-a127-e56c0172c292/resourceGroups/rg-logitrack-dev-brazilsouth/providers/Microsoft.Synapse/workspaces/syn-logitrack-dev-brs"
  depends_on = [
    azurerm_synapse_workspace.res-9,
  ]
}
resource "azurerm_synapse_workspace_security_alert_policy" "res-17" {
  policy_state         = "Disabled"
  synapse_workspace_id = "/subscriptions/47aefbfa-9a52-4276-a127-e56c0172c292/resourceGroups/rg-logitrack-dev-brazilsouth/providers/Microsoft.Synapse/workspaces/syn-logitrack-dev-brs"
  depends_on = [
    azurerm_synapse_workspace.res-9,
  ]
}

