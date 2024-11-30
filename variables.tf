variable "values" {
  description = "information about the domain and records to be created."
  type = object({
    domain = string
    records = optional(map(list(object({
      name  = string
      value = string
      ttl = optional(number, -1)
    }))), {}),
    atproto = optional(list(object({
      handle = string
      did    = string
    })), [])
  })
}

variable "default_ttl" {
    description = "Default TTL value. DNS requires a TTL value to be the same across records with the same FQDN, so this is used for all records on any FQDN where none of the records has a specified TTL."
    type = number
    default = 1799
}

output "domain" {
  description = "the domain resource"
  value = digitalocean_domain.domain
}

output "records" {
    description = "the non-atproto domain records resources"
    value = digitalocean_record.records
}

output "atproto" {
    description = "the atproto domain record resources"
    value = digitalocean_record.atproto
}