locals {
    val = yamldecode(file("./tests/basic_pass/test_config.yml"))
    noatproto = yamldecode(file("./tests/basic_pass/noatproto.yml"))
    onlyatproto = yamldecode(file("./tests/basic_pass/onlyatproto.yml"))
}

module "example_dns" {
    source = "../.."
    domain = "anexample.com"
    values = local.val
}

module "noatproto" {
    source = "../.."
    domain = "anexample2.com"
    values = local.noatproto
}

module "onlyatproto" {
    source = "../.."
    domain = "anexample3.com"
    values = local.onlyatproto
}