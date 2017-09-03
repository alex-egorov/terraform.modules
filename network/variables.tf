variable "name"                 { }
variable "owner"                { }

variable "cidr_block"           { }
variable "enable_dns_hostnames" { default = true }
variable "enable_dns_support"   { default = true }
variable "azs"                  { type="list" }

variable "enable_nat_gateway" {
  description = "should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "should be false if you do not want to auto-assign public IP on launch"
  default     = false
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate."
  default     = []
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = []
}

variable "public_subnets"         { type="list" }

variable "private_subnets"        { type="list" }
