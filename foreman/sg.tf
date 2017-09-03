################################# SECURITY GROUP ###############################

resource "aws_security_group" "foreman" {
  name   = "${var.name}-foreman-sgs"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port       = 53
    to_port         = 53
    protocol        = "tcp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  ingress {
    from_port       = 67
    to_port         = 69
    protocol        = "udp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  ingress {
    from_port       = 5910
    to_port         = 5930
    protocol        = "tcp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  ingress {
    from_port       = 8140
    to_port         = 8140
    protocol        = "tcp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    cidr_blocks     = ["${data.terraform_remote_state.vpc.cidr_block}"]
  }

  tags {
    Name      = "${var.name}_sg_foreman"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }

}
