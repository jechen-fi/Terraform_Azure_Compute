data "template_file" "domainjoin" {
    template = "${file("./modules/compute/virtual_machines/domain_join_win.ps1")}"
    vars = {
        appworkloadgroup        = "${var.app_workload_group}"
  }
} 