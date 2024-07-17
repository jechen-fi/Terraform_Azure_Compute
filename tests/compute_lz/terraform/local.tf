locals {

  # Convert YAML settings file to Terraform Configuration file format
  settings = yamldecode(file("../environments/${terraform.workspace}/settings.yaml"))

  networking = merge(module.networking_reused)

  disk_encryption_sets = merge(module.disk_encryption_set)

  #virtual_machines = merge(module.virtual_machines)

}