variable "name"            { }
variable "owner"           { }
variable "vpc_id"          { }
variable "cidr_block"      { }
variable "trusted_subnets" { type = "list" default = [] }
