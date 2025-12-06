terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "StorageRG"
    storage_account_name = "tasboardstorage"
    container_name       = "taksboardfolder"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
# resource group
resource "azurerm_resource_group" "arg" {
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_location_name
}
# App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "${var.app_service_plan_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  os_type             = var.app_service_plan_os
  sku_name            = var.app_service_plan_sku
}
# Azure linux webapp
resource "azurerm_linux_web_app" "app" {
  name                = "${var.app_service_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.database.name};User ID=${azurerm_mssql_server.sqlserver.administrator_login};Password=${azurerm_mssql_server.sqlserver.administrator_login_password};Trusted_Connection=False;"
  }
  site_config {
    application_stack {
      dotnet_version = var.app_service_stack_dotnet_version
    }
    always_on = false
  }
}
# db server
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${var.sql_server_name}${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = var.sql_server_version
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}
# database
resource "azurerm_mssql_database" "database" {
  name           = "${var.sql_database_name}${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.sqlserver.id
  collation      = var.sql_database_collation
  license_type   = var.sql_database_license_type
  max_size_gb    = 2
  sku_name       = var.sql_database_sku
  zone_redundant = false
  # geo_backup_enabled   = false
  storage_account_type = var.sql_database_storage_account_type
}
# database firewall
resource "azurerm_mssql_firewall_rule" "firewall-rule-1" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = var.firewall_rule_start_ip
  end_ip_address   = var.firewall_rule_end_ip
}
# deploy from github
resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.app.id
  repo_url               = var.repo_URL
  branch                 = var.repo_branch
  use_manual_integration = true
}

