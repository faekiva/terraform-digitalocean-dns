output "records" {
    description = "the non-atproto domain records resources"
    value = digitalocean_record.records
}

output "atproto" {
    description = "the atproto domain record resources"
    value = digitalocean_record.atproto
}

output "domain" {
    description = "the domain resource"
    value = digitalocean_domain.domain
}