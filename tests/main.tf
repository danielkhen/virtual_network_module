locals {
  location            = "westeurope"
  resource_group_name = "dtf-virtual-network-test"
}

resource "azurerm_resource_group" "test_rg" {
  name     = local.resource_group_name
  location = local.location

  lifecycle {
    ignore_changes = [tags["CreationDateTime"], tags["Environment"]]
  }
}

locals {
  rt_name = "rt"
}

module "route_table" {
  source = "../../route_table"

  name                = local.rt_name
  location            = local.location
  resource_group_name = azurerm_resource_group.test_rg.name
}

locals {
  vnet_name          = "vnet"
  vnet_address_space = ["10.0.0.0/16"]
  vnet_dns_servers   = ["11.0.0.0"]

  vnet_subnets = [
    {
      name           = "TestSubnet"
      address_prefix = "10.0.0.0/24"
      route_table_id = module.route_table.id
    }
  ]
}

module "vnet" {
  source = "../"

  name                = local.vnet_name
  location            = local.location
  resource_group_name = azurerm_resource_group.test_rg.name
  address_space       = local.vnet_address_space
  dns_servers         = local.vnet_dns_servers
  subnets             = local.vnet_subnets
}
