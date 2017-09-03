variable "name"                  { }
variable "prefix"                { }
variable "owner"                 { }
variable "key_name"              { }

variable "vpc_id"                { }
variable "trusted_subnets"       { type="list", default = [] }

variable "ec2_subnet_id"         { }
variable "ec2_ami_id"            { }
variable "ec2_instance"          { default = "t2.micro" }
variable "ec2_private_ip"        { }
variable "ec2_security_groups"   { type="list", default = [] }
variable "ec2_ebs_optimized"     { default = false }
variable "ec2_ebs_root_size"     { default = 8 }
variable "ec2_associate_public_ip"     { default = true }
variable "ec2_disable_api_termination" { default = false }
