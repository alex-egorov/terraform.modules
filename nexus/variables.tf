variable "name"       { }
variable "prefix"     { }
variable "owner"      { }
variable "key_name"   { }

variable "vpc_id"     { }
variable "trusted_subnets" { default = [] }

variable "ec2_subnet_id"         { }
variable "ec2_ami_id"            { }
variable "ec2_instance"          { default = "t2.small" }
variable "ec2_private_ip"        { }
variable "ec2_security_groups"   { default = [] }
variable "ec2_ebs_optimized"     { default = false }
variable "ec2_ebs_root_size"     { default = 20 }
variable "ec2_ebs_storage_size"  { default = 50 }
variable "ec2_version"           { default = "3.2.0" }
variable "ec2_hostname"          { }
variable "ec2_mount_point"       { default = "/mnt/nexus_storage" }
variable "ec2_associate_public_ip"     { default = false }
variable "ec2_disable_api_termination" { default = false }

variable "java_max_mem"           { default = "1200m" }
variable "java_min_mem"           { default = "1200m" }
variable "extra_java_opts"        { default = "" }
variable "context_path"           { default = "/" }
