locals {
    dns_files_dir = "${path.module}/dns"
}

module "dns" {
    for_each = fileset(local.dns_files_dir, "**.{yml,yaml}")
    source = "../.."
    values = yamldecode(file("${local.dns_files_dir}/${each.value}"))
}
