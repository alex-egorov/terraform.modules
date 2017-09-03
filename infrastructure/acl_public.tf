### ACL for public subnets

resource "aws_network_acl" "public" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${var.public_subnet_ids}"]

  tags {
   Name = "${var.name}-acl-public"
   Terraform = "Terraform"
   Created = "${var.owner}"
  }
}

# inbound icmp from all
resource "aws_network_acl_rule" "public_allow_inbound_icmp_rule" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress = false
  protocol = "icmp"
  rule_number = 100
  rule_action = "allow"
  cidr_block =  "0.0.0.0/0"
  icmp_type = -1
  icmp_code = -1
}

# inbound ssh(22) rule for trusted subnets
resource "aws_network_acl_rule" "public_allow_ssh_from_trusted_subnets" {
  network_acl_id = "${aws_network_acl.public.id}"
  count = "${length(var.trusted_subnets)}"

  egress = false
  protocol = "tcp"
  rule_number = "${110+count.index}"
  rule_action = "allow"
  cidr_block =  "${element(var.trusted_subnets, count.index)}"
  from_port = 22
  to_port = 22
}

# inbound http(80) traffic from anywhere
resource "aws_network_acl_rule" "public_allow_inbound_http_anywhere" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress = false
  protocol = "tcp"
  rule_number = 120
  rule_action = "allow"
  cidr_block =  "0.0.0.0/0"
  from_port = 80
  to_port = 80
}

# inbound https(443) traffic from anywhere
resource "aws_network_acl_rule" "public_allow_inbound_https_anywhere" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress = false
  protocol = "tcp"
  rule_number = 130
  rule_action = "allow"
  cidr_block =  "0.0.0.0/0"
  from_port = 443
  to_port = 443
}

# inbound 32768-65535 tcp ephemeral ports
# Allows inbound return traffic from requests originating in the subnet.
resource "aws_network_acl_rule" "public_allow_inbound_empheral_rule" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress = false
  protocol = "tcp"
  rule_number = 500
  rule_action = "allow"
  cidr_block =  "0.0.0.0/0"
  from_port = 1024
  to_port = 65535
}


# inbound npt(123) udp traffic
resource "aws_network_acl_rule" "public_allow_inbound_ntp_rule" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress = false
  protocol = "udp"
  rule_number = 550
  rule_action = "allow"
  cidr_block =  "0.0.0.0/0"
  from_port = 123
  to_port = 123
}

# all inbound traffic from vpc
resource "aws_network_acl_rule" "public_allow_inbound_tcp_from_network" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress = false
  protocol = "-1"
  rule_number = 800
  rule_action = "allow"
  cidr_block =  "${var.cidr_block}"
}

## OUTBOUND RULES

# all allowed
resource "aws_network_acl_rule" "public_allow_outbound_rule" {
  network_acl_id = "${aws_network_acl.public.id}"
  egress = true
  protocol = "-1"
  rule_number = 100
  rule_action = "allow"
  cidr_block =  "0.0.0.0/0"
}


output "public_acl" {
  value = "${aws_network_acl.public.id}"
}
