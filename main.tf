data "azurerm_client_config" "current" {}
 
terraform {
    backend "local" {
    }
}
 
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create Storage Account
resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
 
  tags = {
    environment = local.environment
  }
}

data "azurerm_key_vault_secret" "sql_server_adminUser" {
  name         = "sql-server-adminUser"
  key_vault_id = var.azure_keyvault_id
}

data "azurerm_key_vault_secret" "sql_server_adminPwd" {
  name         = "sql-server-adminPwd"
  key_vault_id = var.azure_keyvault_id
}

resource "azurerm_mssql_server" "example" {
  name                         = "ssql-ah-terraform"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  administrator_login          = data.azurerm_key_vault_secret.sql_server_adminUser.value
  administrator_login_password = data.azurerm_key_vault_secret.sql_server_adminPwd.value
  version                      = "12.0"
   tags = {
    environment = local.environment
  }
}

resource "azurerm_mssql_database" "serverless_db" {
    name                        = "db-ah-terraform"
    server_id                   = azurerm_mssql_server.example.id
    collation                   = "SQL_Latin1_General_CP1_CI_AS"

    auto_pause_delay_in_minutes = 60
    max_size_gb                 = 32
    min_capacity                = 0.5
    read_replica_count          = 0
    read_scale                  = false
    sku_name                    = "GP_S_Gen5_1"
    zone_redundant              = false

    threat_detection_policy {
        disabled_alerts      = []
        email_account_admins = "Disabled"
        email_addresses      = []
        retention_days       = 0
        state                = "Disabled"
        # use_server_default   = "Disabled"
    }

    tags = {
      environment = "dev"
    }
}

data "http" "current_ip" {
  url = "https://ipinfo.io/ip"
}

resource "azurerm_sql_firewall_rule" "example" {
  name                = "AllowClientIP"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mssql_server.example.name
  start_ip_address    = trimspace(data.http.current_ip.body)
  end_ip_address      = trimspace(data.http.current_ip.body)
}