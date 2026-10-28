provider "azurerm" {
  features {}

  # Obbligatorio da azurerm 4.x. Se null, viene letta la variabile d'ambiente ARM_SUBSCRIPTION_ID
  subscription_id = var.subscription_id
}
