variable "length" {
  default = "14"
}

resource "random_id" "password" {
  byte_length = "${var.length * 3 / 4}"
}
