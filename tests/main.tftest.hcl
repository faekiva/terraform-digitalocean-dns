# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option

# Configure the DigitalOcean Provider
provider "digitalocean" {
}

# variables {
#   domain = "example.com"
#   values = yamldecode("test_config.yml")
# }

run "test_apply" {
    module {
        source = "./tests/basic_pass"
    }
    command = apply
}