variable "name"               { }
variable "owner"              { }
variable "vpc_id"             { }
variable "cidr_block"         { }
variable "trusted_subnets"    { type = "list" default = [] }
variable "public_subnet_ids"  { type = "list" default = [] }
variable "private_subnet_ids" { type = "list" default = [] }
