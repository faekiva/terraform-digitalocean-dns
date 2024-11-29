resource "digitalocean_domain" "domain" {
  name = var.domain
}

locals {
    records_tmp = toset(flatten([
        for typeKey, type in var.values.records: [
            for record in type: {
                type = typeKey
                name = trimsuffix(trimsuffix(record.name, "${var.domain}"), ".") == "" ? "@" : trimsuffix(trimsuffix(record.name, "${var.domain}"), ".")
                value = type == "CNAME" ? "${trimsuffix(record.value, ".")}." : record.value
                ttl = try(record.ttl, null)
            }
        ]
    ]))
    records = {for record in local.records_tmp: base64sha256("${record.type}${record.name}${record.value}") => record}
    atproto = {for record in var.values.atproto: record.handle => record}
}

resource "digitalocean_record" "records" {
  for_each = local.records
  domain = digitalocean_domain.domain.name
  type = each.value.type
  name = each.value.name
  value = each.value.value
  ttl = each.value.ttl
}

resource "digitalocean_record" "atproto" {
  for_each = local.atproto
  domain = digitalocean_domain.domain.name
  type = "TXT"
  name = trimprefix(trimsuffix(each.value.handle, var.domain),"@") == "" ? "@" : trimprefix(trimsuffix(each.value.handle, var.domain),"@")
  value = startswith(each.value.did, "did=") ? each.value.did : "did=${each.value.did}"
}