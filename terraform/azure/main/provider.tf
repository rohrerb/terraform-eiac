provider "azurerm" {
  subscription_id = var.subscription_id
}

provider "azuread" {
  alias           = "ad"
  subscription_id = var.subscription_id
}

provider "random" {}

provider "null" {}
