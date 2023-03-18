data "azurerm_resource_group" "udacity" {
  name     = "Regroup_0smDER1LA"
}

resource "azurerm_container_group" "udacity" {
  name                = "udacity-continst"
  location            = data.azurerm_resource_group.udacity.location
  resource_group_name = data.azurerm_resource_group.udacity.name
  ip_address_type     = "Public"
  dns_name_label      = "udacity-jungle-azure"
  os_type             = "Linux"

  container {
    name   = "azure-container-app"
    image  = "docker.io/tscotto5/azure_app:1.0"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      "AWS_S3_BUCKET"       = "udacity-jungle-aws-s3-bucket",
      "AWS_DYNAMO_INSTANCE" = "udacity-jungle-aws-dynamodb"
    }
    ports {
      port     = 3000
      protocol = "TCP"
    }
  }
  tags = {
    environment = "udacity"
  }
}

####### Your Additions Will Start Here ######

resource "azurerm_sql_server" "example" {
  name                         = "udacity-jungle-azure-sql-server"
  resource_group_name          = data.azurerm_resource_group.udacity.name
  location                     = data.azurerm_resource_group.udacity.location
  version                      = "12.0"
  administrator_login          = "jungle-admin"
  administrator_login_password = "jngpassword123*"

  tags = {
    environment = "production"
  }
}

resource "azurerm_sql_database" "example" {
  name                = "udacity-jungle-azure-sql-database"
  resource_group_name = data.azurerm_resource_group.udacity.name
  location            = data.azurerm_resource_group.udacity.location
  server_name         = azurerm_sql_server.example.name

  tags = {
    environment = "production"
  }
}


resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan"
  location            = data.azurerm_resource_group.udacity.location
  resource_group_name = data.azurerm_resource_group.udacity.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "udacity-jungle-azure-dotnet-app"
  location            = data.azurerm_resource_group.udacity.location
  resource_group_name = data.azurerm_resource_group.udacity.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }
}
