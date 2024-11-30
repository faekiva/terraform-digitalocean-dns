variable "domain" {
  type = string
}

variable "values" {
  type = object({
    records = map(list(object({
      name  = string
      value = string
    }))),
    atproto = list(object({
      handle = string
      did    = string
    }))
  })
}

output "records" {
    value = digitalocean_record.records
}

output "atproto" {
    value = digitalocean_record.atproto
}