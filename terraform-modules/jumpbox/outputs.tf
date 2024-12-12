output "vm_identity" {
  value = module.virtual-machine.vm_identity[0].principal_id
}
output "vm_id" {
  value = module.virtual-machine.vm_id
}
output "vm_ip" {
  value = module.virtual-machine.network_interface_private_ip
}
output "vm_name" {
  value = module.virtual-machine.vm_name
}