################################# SECURITY GROUP ###############################

resource "aws_security_group" "nexus" {
  name   = "${var.prefix}-${var.name}-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    cidr_blocks     = ["${var.trusted_subnets}"]
  }
}
