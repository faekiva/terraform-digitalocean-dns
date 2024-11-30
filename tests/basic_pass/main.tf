locals {
    val = yamldecode(file("./tests/basic_pass/test_config.yml"))
    noatproto = yamldecode(file("./tests/basic_pass/noatproto.yml"))
    onlyatproto = yamldecode(file("./tests/basic_pass/onlyatproto.yml"))
}

module "example_dns" {
    source = "../.."
    values = local.val
}

module "noatproto" {
    source = "../.."
    values = local.noatproto
}

module "onlyatproto" {
    source = "../.."
    values = local.onlyatproto
}