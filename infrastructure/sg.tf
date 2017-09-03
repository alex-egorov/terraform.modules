
## All opened - !!! Delete it in Production
resource "aws_security_group" "all" {
  name     = "${var.name}-all-opened-sg"
  vpc_id   = "${var.vpc_id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "${var.name}-sg-all-opened-DELETE_IT_FROM_PRODUCTION"
    Warning   = "DELETE_IT_FROM_PRODUCTION"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

output "all" {
  value = "${aws_security_group.all.id}"
}

## outbound

resource "aws_security_group" "outbound" {
  name   = "${var.name}-outbound-sg"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags {
    Name      = "${var.name}-outbound-sg"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

output "outbound" {
  value = "${aws_security_group.outbound.id}"
}

## public

resource "aws_security_group" "public" {
  name   = "${var.name}-public-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.trusted_subnets}", "${var.cidr_block}"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.trusted_subnets}", "${var.cidr_block}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.trusted_subnets}", "${var.cidr_block}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags {
    Name      = "${var.name}-sgpublic"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

output "public_sg" {
  value = "${aws_security_group.public.id}"
}

## private
resource "aws_security_group" "private" {
  name   = "${var.name}-private-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [ "${aws_security_group.bastion.id}" ]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}", "${var.trusted_subnets}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}", "${var.trusted_subnets}"]
  }

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}", "${var.trusted_subnets}"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.cidr_block}", "${var.trusted_subnets}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "${var.name}-sgapp"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

output private {
  value = "${aws_security_group.private.id}"
}

## bastion

resource "aws_security_group" "bastion" {
  name     = "${var.name}-bastion-sg"
  vpc_id   = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "${var.trusted_subnets}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "${var.cidr_block}", "${var.trusted_subnets}"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["${var.cidr_block}", "${var.trusted_subnets}"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "${var.name}-bastion-sg"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

output "bastion-sg" {
  value = "${aws_security_group.bastion.id}"
}

## elb

resource "aws_security_group" "elb" {
  name        = "${var.name}-elb-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags {
    Name      = "${var.name}-elb-sg"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

output elb {
  value = "${aws_security_group.elb.id}"
}
