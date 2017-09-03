resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags {
    Name = "${var.name}"
    Terraform = "Terraform"
    Created = "${var.owner}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-igw"
    Terraform = "Terraform"
    Created = "${var.owner}"
  }
}

## public routes

resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${var.public_propagating_vgws}"]

  tags {
    Name = "${var.name}-rt-public"
    Terraform = "Terraform"
    Created = "${var.owner}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

## private routes

resource "aws_route_table" "private" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${var.private_propagating_vgws}"]
  count            = "${length(var.private_subnets)}"

  tags {
    Name = "${var.name}-rt-private-${element(var.private_subnets, count.index)}"
    Terraform = "Terraform"
    Created = "${var.owner}"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.natgw.*.id, count.index)}"
  count                  = "${length(var.private_subnets) * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"
}

## nat gateway

resource "aws_eip" "nateip" {
  vpc   = true
  count = "${length(var.azs) * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${element(aws_eip.nateip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  count         = "${length(var.azs) * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"

  depends_on = ["aws_internet_gateway.igw"]
}

## public subnets
##
##
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.public_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count             = "${length(var.azs)}"

  tags {
    Name = "${var.name}-public-${element(var.azs, count.index)}"
    Terraform = "Terraform"
    Created = "${var.owner}"
  }

  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
}

# route tabe for public subnets
resource "aws_route_table_association" "public" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}


resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  count             = "${length(var.private_subnets)}"

  tags {
    Name = "${var.name}-private-${element(var.private_subnets, count.index)}"
    Terraform = "Terraform"
    Created = "${var.owner}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  depends_on = ["aws_subnet.private"]
}
