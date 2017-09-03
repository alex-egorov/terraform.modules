################################# SECURITY GROUP ###############################

resource "aws_security_group" "bitbucket" {
  name   = "${var.prefix}-${var.name}-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["${var.trusted_subnets}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["${var.trusted_subnets}"]
  }

  ingress {
    from_port       = 7999
    to_port         = 7999
    protocol        = "tcp"
    cidr_blocks     = ["${var.trusted_subnets}"]
  }

  tags {
    Name      = "${var.prefix}-${var.name}-sg"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

resource "aws_security_group" "db_bitbucket" {
  name   = "${var.prefix}-${var.name}-db-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = ["${var.ec2_private_ip}/32"]
  }
}
