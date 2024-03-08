data "template_file" "domainjoin" {
    template = "${file("./modules/compute/virtual_machines/domain_join_win.ps1")}"
    vars = {
        appworkloadgroup        = "${var.app_workload_group}"
        keyvaultdomaintoken     = "${var.keyvault_domain_token}"
        domainsvcaccount        = "${var.domain_svc_account}"
  }
} 