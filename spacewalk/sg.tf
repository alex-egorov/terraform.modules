################################# SECURITY GROUP ###############################

resource "aws_security_group" "spacewalk" {
  name   = "${var.name}_sg_spacewalk"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 4545
    to_port         = 4545
    protocol        = "tcp"
    cidr_blocks     = ["${var.trusted_subnets}"]
  }

  ingress {
    from_port       = 5222
    to_port         = 5222
    protocol        = "tcp"
    cidr_blocks     = ["${var.trusted_subnets}"]
  }

  ingress {
    from_port       = 5269
    to_port         = 5269
    protocol        = "tcp"
    cidr_blocks     = ["${var.trusted_subnets}"]
  }

  ingress {
    from_port       = 69
    to_port         = 69
    protocol        = "tcp"
    cidr_blocks     = ["${var.trusted_subnets}"]
  }

  ingress {
    from_port       = 69
    to_port         = 69
    protocol        = "udp"
    cidr_blocks     = ["${var.trusted_subnets}"]
  }
}
