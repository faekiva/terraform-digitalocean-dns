variable "getHashed" {
  type = string
}

output "hashed" {
  value = base64sha256(var.getHashed)
}