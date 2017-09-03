variable "name"       { }
variable "prefix"     { }
variable "owner"      { }
variable "key_name"   { }

variable "organization" { }
variable "city"         { }
variable "state"        { }
variable "country"      { }

variable "vpc_id"     { }
variable "trusted_subnets" { default = [] }

variable "ec2_subnet_id"         { }
variable "ec2_ami_id"            { }
variable "ec2_instance"          { default = "t2.medium" }
variable "ec2_private_ip"        { }
variable "ec2_security_groups"   { default = [] }
variable "ec2_ebs_optimized"     { default = false }
variable "ec2_ebs_root_size"     { default = 20 }
variable "ec2_ebs_storage_size"  { default = 50 }
variable "ec2_version"           { default = "3.2.0-01" }
variable "ec2_hostname"          { }
variable "ec2_mount_point"       { default = "/mnt/spacewalk_data" }
variable "ec2_associate_public_ip"     { default = false }
variable "ec2_disable_api_termination" { default = false }
