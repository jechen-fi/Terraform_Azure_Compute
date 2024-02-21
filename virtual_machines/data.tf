#Variable input for the ADDS.ps1 script
data "template_file" "domain_join_win" {
    template = "${file("domain_join_win.ps1")}"
    vars = {
        keyvault_domain_token  = "${var.keyvault_domain_token}"
        app_workload_group     = "${var.app_workload_group}"
  }
}