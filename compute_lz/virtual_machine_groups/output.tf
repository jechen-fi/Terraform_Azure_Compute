output "virtual_machines_in_group" {
  description = "All virtual machines created via virtual_machine_groups module"
  value = {
    # Build map with VM Name as key
    for key, value in module.virtual_machines_in_group : value.name => value
  }
}