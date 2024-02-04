resource "azurerm_servicebus_namespace" "k8s-az-func-sb" {
  name                = "sb-k8s-az-func"
  location            = data.azurerm_resource_group.k8s-az-func-demo.location
  resource_group_name = data.azurerm_resource_group.k8s-az-func-demo.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "k8s-az-func-sb-queue" {
  name         = "sb-queue-k8s-az-func"
  namespace_id = azurerm_servicebus_namespace.k8s-az-func-sb.id

  enable_partitioning = true
}

output ServiceBus_ConnectionString {
  sensitive = true
  value = azurerm_servicebus_namespace.k8s-az-func-sb.default_primary_connection_string
}

output ServiceBus_QueueName {
  value = azurerm_servicebus_queue.k8s-az-func-sb-queue.name
}