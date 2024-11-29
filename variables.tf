variable "domain" {
  type = string
}

variable "values" {
  type = object({ 
    records = map(list(object({
        name = string
        value = string
        ttl = string
    }))),
    atproto = list(object({
        handle = string
        did = string
    }))
  })
}
