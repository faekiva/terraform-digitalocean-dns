# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option

# Configure the DigitalOcean Provider
provider "digitalocean" {
}

# variables {
#   domain = "example.com"
#   values = yamldecode("test_config.yml")
# }

run "basic_pass" {
    module {
        source = "./tests/basic_pass"
    }
    command = apply

    assert {
        condition = anytrue([
            for record in module.example_dns.records: record.type == "CNAME" && record.name == "wow" && record.value == "google.com."
        ])
        error_message = "record 'wow' incorrect."
    }

    assert {
        condition = anytrue([
            for record in module.example_dns.records: record.type == "CNAME" &&
             record.name == "wee" && record.value == "google.com."
        ])
        error_message = "record 'wee' incorrect."
    }

    assert {
        condition = anytrue([
            for record in module.example_dns.records: record.type == "CNAME" &&
             record.name == "wee" && record.value == "google.com."
        ])
        error_message = "record 'wee' incorrect."
    }

    assert {
        condition = anytrue([
            for record in module.example_dns.records: record.type == "A" &&
             record.name == "boop" && record.value == "8.8.8.8"
        ])
        error_message = "record 'boop' incorrect."
    }

    assert {
        condition = anytrue([
            for record in module.example_dns.records: record.type == "A" &&
             record.name == "boop" && record.value == "8.8.8.8"
        ])
        error_message = "record 'boop' incorrect."
    }

    assert {
        condition = anytrue([
            for record in module.example_dns.records: record.type == "A" &&
             record.name == "@" && record.value == "127.0.0.1" #&& record.ttl == 9001
        ])
        error_message = "record 'boop' incorrect."
    }
}

run "pass_no_atproto" {
    module {
        source = "./tests/pass_no_atproto"
    }
    command = apply
}