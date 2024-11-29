locals {
    val = yamldecode(file("./tests/basic_pass/test_config.yml"))
}

module "example_dns" {
    source = "../.."
    domain = "example.com"
    values = local.val
}