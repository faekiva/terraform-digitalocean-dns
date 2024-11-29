resource "digitalocean_domain" "domain" {
  name = var.domain
}

locals {
    records_tmp = toset(flatten([
        for typeKey, type in var.values.records: [
            for record in type: {
                type = type
                name = trimsuffix(trimsuffix(record.name, "${var.domain}"), ".") == "" ? "@" : trimsuffix(trimsuffix(record.name, "${var.domain}"), ".")
                value = type == "CNAME" ? "${trimsuffix(record.value, ".")}." : record.value
                ttl = try(record.ttl, null)
            }
        ]
    ]))
}

resource "digitalocean_record" "records" {
  for_each = local.records_tmp
  domain = digitalocean_domain.domain.name
  type = each.key
  name = each.value.name
  value = each.value.value
  ttl = each.value.ttl
}

resource "digitalocean_record" "atproto" {
  for_each = var.values.atproto
  domain = digitalocean_domain.domain.name
  type = "TXT"
  name = trimprefix(trimsuffix(each.value.name, var.domain),"@") == "" ? "@" : trimprefix(trimsuffix(each.value.name, var.domain),"@")
  value = startswith(each.value.value, "did=") ? each.value.value : "did=${each.value.value}"
}