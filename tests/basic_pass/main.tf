locals {
    val = yamldecode("test_config.yml")
}

module "example_dns" {
    source = "../.."
    domain = "example.com"
    values = local.val
}