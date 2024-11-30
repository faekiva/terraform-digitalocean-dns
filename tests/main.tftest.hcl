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
            for record in module.example_dns.records: record.type == "A" &&
             record.name == "boop" && record.value == "8.8.8.8"
        ])
        error_message = "record 'boop' incorrect."
    }

    assert {
        condition = anytrue([
            for record in [module.example_dns.records["A | @ | 127.0.0.1"]]: record.type == "A" &&
             record.name == "@" && record.value == "127.0.0.1" && record.ttl == 9001
        ])
        error_message = "A record '@' incorrect. TYPE = ${module.example_dns.records["A | @ | 127.0.0.1"].type} | NAME = ${module.example_dns.records["A | @ | 127.0.0.1"].name} | VALUE = ${module.example_dns.records["A | @ | 127.0.0.1"].value} | TTL = ${module.example_dns.records["A | @ | 127.0.0.1"].ttl}"
    }

    assert {
        condition = anytrue([
            for record in module.example_dns.records: record.type == "TXT" &&
             record.name == "@" && record.value == "v=spf1 include:spf.messagingengine.com ?all" && record.ttl == 9001
        ])
        error_message = "TXT record '@' incorrect. TYPE = ${module.example_dns.records["TXT | @ | v=spf1 include:spf.messagingengine.com ?all"].type} | NAME = ${module.example_dns.records["TXT | @ | v=spf1 include:spf.messagingengine.com ?all"].name} | VALUE = ${module.example_dns.records["TXT | @ | v=spf1 include:spf.messagingengine.com ?all"].value} | TTL = ${module.example_dns.records["TXT | @ | v=spf1 include:spf.messagingengine.com ?all"].ttl}"
    }

    assert {
        condition = module.example_dns.atproto["did:plc:mgirdry3xewuqjnknhkxxphd"].name == "_atproto.beingthecowboy" && module.example_dns.atproto["did:plc:mgirdry3xewuqjnknhkxxphd"].value == "did=did:plc:mgirdry3xewuqjnknhkxxphd"
        error_message = "record 'beingthecowboy' incorrect"
    }

    assert {
        condition = module.example_dns.atproto["did:plc:lodvu673l7mrw3tyevt7vl4e"].name == "_atproto" && module.example_dns.atproto["did:plc:lodvu673l7mrw3tyevt7vl4e"].value == "did=did:plc:lodvu673l7mrw3tyevt7vl4e"
        error_message = "record 'anexample' incorrect"
    }

    assert {
        condition = module.example_dns.atproto["did:plc:eeeeeeeeeeeeeeeeeeeeeeee"].name == "_atproto.me" && module.example_dns.atproto["did:plc:eeeeeeeeeeeeeeeeeeeeeeee"].value == "did=did:plc:eeeeeeeeeeeeeeeeeeeeeeee"
        error_message = "record 'me' incorrect"
    }

    assert {
        condition = length(module.noatproto.atproto) == 0
        error_message = "atproto records created unepectedly for noatproto"
    }

    assert {
        condition = length(module.onlyatproto.records) == 0
        error_message = "non atproto records created unepectedly for onlyatproto"
    }
}