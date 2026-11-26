##create a file instance-varaibles.tf copy from line 2 till 18 
  variable "linux_vms" {
  description = "linux vm configuration across az"
  type = map(object({
    vm_size = string
    zone    = string
  }))
  default = {
    "web1" = {
      vm_size = "Standard_F2"
      zone    = "1"
    }
    "web2" = {
      vm_size = "Standard_D2_v3"
      zone    = "2"
    }
  }
}

##go inside public.tf file delete everyting copy from line 21 till 31
  resource "azurerm_public_ip" "web_vm_publicip" {
  for_each            = var.linux_vms
  name                = "${local.resource_name_prefix}-${each.key}-publicip"
  location            = azurerm_resource_group.my_rg.location #it get from the state file
  resource_group_name = azurerm_resource_group.my_rg.name
  allocation_method   = "Static"
  sku                 = "Standard" #basic it will create the public ip in single az standard it will spread across all the az in your region
  zones               = [each.value.zone]
  tags = {
    environment = "Production"
  }
}

#go inside nic.tf file delete everything add this from line 35 till 51
  resource "azurerm_network_interface" "web_nic" {
  for_each            = var.linux_vms
  name                = "${local.resource_name_prefix}-${each.key}-nic"
  location            = azurerm_resource_group.my_rg.location #it get from the state file
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_vm_publicip[each.key].id
  }
}
/*
output "instance_publicip" {
  value = azurerm_public_ip.web_vm_publicip.ip_address
}*/

#go inside vm.tf file delete everythinbg copy from line 54 till 84
  resource "azurerm_linux_virtual_machine" "web_vm" {
    for_each = var.linux_vms
  name                = "${local.resource_name_prefix}-${each.key}-vm"
  location            = azurerm_resource_group.my_rg.location #it get from the state file
  resource_group_name = azurerm_resource_group.my_rg.name
  size                = each.value.vm_size
  zone = each.value.zone
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.web_nic[each.key].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/ssh-keys/terraform-azure.pem.pub")
    #it will look for file in the current directory
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  custom_data = filebase64("${path.module}/app.sh")
}

#go inside winvm.tf file put /* at the starting and end of the line */

  ##then do terraform plan
  terraform apply
