locals {
  domain = var.values.domain
  records_tmp = toset(flatten([
    for typeKey, type in var.values.records : [
      for record in type : {
        type  = typeKey
        name  = trimsuffix(trimsuffix(record.name, "${local.domain}"), ".") == "" ? "@" : trimsuffix(trimsuffix(record.name, "${local.domain}"), ".")
        value = (typeKey == "CNAME" || typeKey == "MX") ? "${trimsuffix(record.value, ".")}." : record.value
        ttl   = record.ttl
        priority = record.priority
      }
    ]
  ]))
  records_ttl_mapping = {for record in local.records_tmp: record.name => record.ttl if record.ttl != -1}
  records_with_mapped_ttl = [for record in local.records_tmp: {
    type = record.type
    name = record.name
    value = record.value
    ttl = lookup(local.records_ttl_mapping, record.name, var.default_ttl)
    priority = record.priority
  }]
  records = { for record in local.records_with_mapped_ttl : (length("${record.type} | ${record.name} | ${record.value}") > 64 ? base64sha256("${record.type} | ${record.name} | ${record.value}") : "${record.type} | ${record.name} | ${record.value}") => record }
  atproto_tmp = [ for record in var.values.atproto : {
    type = "TXT"
    name     = "_atproto${trimprefix(trimsuffix(record.handle, local.domain), "@")}" == "_atproto" ? "_atproto" : "_atproto.${trimsuffix(trimprefix(trimsuffix(record.handle, local.domain), "@"), ".")}"
    value    = startswith(record.did, "did=") ? record.did : "did=${record.did}"
  } ]
  atproto = {for record in local.atproto_tmp: trimprefix(record.value, "did=") => {
    type = record.type
    name = record.name
    value = record.value
    ttl = lookup(local.records_ttl_mapping, record.name, var.default_ttl)
  }}
}

resource "digitalocean_domain" "domain" {
  name = local.domain
}

resource "digitalocean_record" "records" {
  for_each = local.records
  domain   = digitalocean_domain.domain.name
  type     = each.value.type
  name     = each.value.name
  value    = each.value.value
  ttl      = each.value.ttl
  priority = each.value.priority
}

resource "digitalocean_record" "atproto" {
  for_each = local.atproto
  domain   = digitalocean_domain.domain.name
  type     = each.value.type
  name     = each.value.name
  value    = each.value.value
  ttl      = each.value.ttl
}