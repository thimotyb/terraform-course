resource "random_string" "rand" {
  length  = 24
  special = false
  upper   = false
}

locals {
  namespace = substr(join("-", [var.namespace, random_string.rand.result]), 0, 24)
}

resource "azurerm_resource_group" "default" {
  name     = local.namespace
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = random_string.rand.result
  resource_group_name      = azurerm_resource_group.default.name
  location                 = azurerm_resource_group.default.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "serverless"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

module "ballroom" {
  source = "terraform-in-action/ballroom/azure"
}

resource "azurerm_storage_blob" "storage_blob" {
  name                 = "server.zip"
  storage_container_id = azurerm_storage_container.storage_container.id
  type                 = "Block"
  source               = module.ballroom.output_path
}

data "azurerm_storage_account_sas" "storage_sas" {
  connection_string = azurerm_storage_account.storage_account.primary_connection_string

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2016-06-19T00:00:00Z"
  expiry = "2048-06-19T00:00:00Z"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}

locals {
  package_url = "https://${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.storage_blob.name}${data.azurerm_storage_account_sas.storage_sas.sas}"
}

resource "azurerm_service_plan" "plan" {
  name                = local.namespace
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_application_insights" "application_insights" {
  name                = local.namespace
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  application_type    = "web"
}

resource "azurerm_linux_function_app" "function" {
  name                = local.namespace
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  storage_account_name        = azurerm_storage_account.storage_account.name
  storage_account_access_key  = azurerm_storage_account.storage_account.primary_access_key
  functions_extension_version = "~4"

  site_config {
    application_insights_key = azurerm_application_insights.application_insights.instrumentation_key

    application_stack {
      node_version = "20"
    }
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE    = local.package_url
    TABLES_CONNECTION_STRING    = data.azurerm_storage_account_sas.storage_sas.connection_string
    AzureWebJobsDisableHomepage = true
  }
}
