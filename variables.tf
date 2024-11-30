variable "domain" {
  type = string
}

variable "values" {
  type = object({
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
    type = number
    default = 1799
}

output "records" {
    value = digitalocean_record.records
}

output "atproto" {
    value = digitalocean_record.atproto
}