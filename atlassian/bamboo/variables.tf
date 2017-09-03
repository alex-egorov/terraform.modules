variable "name"                  { }
variable "prefix"                { }
variable "owner"                 { }
variable "key_name"              { }

variable "vpc_id"                { }
variable "trusted_subnets"       { type="list", default = [] }

variable "db_subnet_ids"         { type="list", default = [] }
variable "db_version"            { default = "9.5.4" }
variable "db_instance"           { default = "db.t2.small" }
variable "db_name"               { default = "bamboo" }
variable "db_username"           { default = "bamboo" }
variable "db_password"           { }
variable "db_storage"            { }
variable "db_security_groups"    { type="list" }
variable "db_backup_retention"   { default = 7 }
variable "db_backup_window"      { default = "07:30-08:30" }
variable "db_maintenance_window" { default = "sun:05:30-sun:07:30" }
variable "db_multi_az"           { default = false }

variable "ec2_subnet_id"         { }
variable "ec2_ami_id"            { }
variable "ec2_instance"          { default = "t2.large" }
variable "ec2_private_ip"        { }
variable "ec2_security_groups"   { type="list", default = [] }
variable "ec2_ebs_optimized"     { default = false }
variable "ec2_ebs_root_size"     { default = 20 }
variable "ec2_associate_public_ip"     { default = false }
variable "ec2_disable_api_termination" { default = false }

variable "version"               { default = "5.14.3.1" }
variable "hostname"              { }
