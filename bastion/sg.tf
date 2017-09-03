################################# SECURITY GROUP ###############################

#resource "aws_security_group" "bastion" {
#  name   = "${var.prefix}-${var.name}-sg"
#  vpc_id = "${var.vpc_id}"
#
#  ingress {
#    from_port       = 22
#    to_port         = 22
#    protocol        = "tcp"
#    cidr_blocks     = ["${var.trusted_subnets}"]
#  }
#
#  tags {
#    Name      = "${var.prefix}-${var.name}-sg"
#    Terraform = "Terraform"
#    Created   = "${var.owner}"
#  }
#}
