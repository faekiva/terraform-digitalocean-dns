locals {
    val = yamldecode(file("./tests/basic_pass/test_config.yml"))
}

module "example_dns" {
    source = "../.."
    domain = "anexample2.com"
    values = local.val
}