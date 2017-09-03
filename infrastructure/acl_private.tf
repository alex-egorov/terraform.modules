### ACL for private subnets
#
# - outbound to anywhere
# - default: deny all


resource "aws_network_acl" "private" {
   vpc_id = "${var.vpc_id}"
   subnet_ids = ["${var.private_subnet_ids}"]

   tags {
     Name = "${var.name}-acl-private"
     Terraform = "Terraform"
     Created = "${var.owner}"
   }
}

## inbound icmp from all
#resource "aws_network_acl_rule" "private_allow_inbound_all" {
#  network_acl_id = "${aws_network_acl.private.id}"
#  egress = false
#  protocol = "-1"
#  rule_number = 100
#  rule_action = "allow"
#  cidr_block =  "0.0.0.0/0"
#}


# inbound icmp from all
resource "aws_network_acl_rule" "private_allow_inbound_icmp_rule" {
  network_acl_id = "${aws_network_acl.private.id}"
  egress = false
  protocol = "icmp"
  rule_number = 100
  rule_action = "allow"
  cidr_block =  "0.0.0.0/0"
  icmp_type = -1
  icmp_code = -1
}

# inbound ssh(22) from vpc network
resource "aws_network_acl_rule" "private_allow_ssh_from_vpc" {
  network_acl_id = "${aws_network_acl.private.id}"
  egress = false
  protocol = "tcp"
  rule_number = 110
  rule_action = "allow"
  cidr_block =  "${var.cidr_block}"
  from_port = 22
  to_port = 22
}

resource "aws_network_acl_rule" "private_allow_ssh_from_trusted_subnets" {
  network_acl_id = "${aws_network_acl.private.id}"
  count = "${length(var.trusted_subnets)}"

  egress = false
  protocol = "tcp"
  rule_number = "${120+count.index}"
  rule_action = "allow"
  cidr_block =  "${element(var.trusted_subnets, count.index)}"
  from_port = 22
  to_port = 22
}

# inbound 32768-65535 tcp ephemeral ports
# Allows inbound return traffic from requests originating in the subnet.
# sudo sysctl net.ipv4.ip_local_port_range
resource "aws_network_acl_rule" "private_allow_inbound_empheral_rule" {
  network_acl_id = "${aws_network_acl.private.id}"
  egress = false
  protocol = "tcp"
  rule_number = 500
  rule_action = "allow"
  cidr_block =  "0.0.0.0/0"
  from_port = 1024
  to_port = 65535
}

# all inbound traffic from vpc
resource "aws_network_acl_rule" "private_allow_inbound_from_network" {
  network_acl_id = "${aws_network_acl.private.id}"
  egress = false
  protocol = "-1"
  rule_number = 800
  rule_action = "allow"
  cidr_block =  "${var.cidr_block}"
}

# all inbound traffic from trusted subnets
resource "aws_network_acl_rule" "private_allow_inbound_from_trusted_subnets" {
  network_acl_id = "${aws_network_acl.private.id}"
  count = "${length(var.trusted_subnets)}"
  egress = false
  protocol = "-1"
  rule_number = "${810+count.index}"
  rule_action = "allow"
  cidr_block =  "${element(var.trusted_subnets, count.index)}"
}

## OUTBOUND RULES

# all allowed
resource "aws_network_acl_rule" "private_allow_outbound_rule" {
  network_acl_id = "${aws_network_acl.private.id}"
  egress = true
  protocol = "-1"
  rule_number = 100
  rule_action = "allow"
  cidr_block =  "0.0.0.0/0"
}



output "private_acl" {
  value = "${aws_network_acl.private.id}"
}
