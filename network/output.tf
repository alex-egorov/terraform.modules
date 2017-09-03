output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "azs" {
  value = "${var.azs}"
}

output "cidr_block" {
  value = "${var.cidr_block}"
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public.*.id}"]
}

output "private_subnet_ids" {
  value = ["${aws_subnet.private.*.id}"]
}

output "nat_gateways" {
  value = ["${aws_nat_gateway.natgw.*.public_ip}"]
}


output "public_route_table_id" {
  value = "${aws_route_table.public.id}"
}

output "private_route_table_ids" {
  value = ["${aws_route_table.private.*.id}"]
}

output "route_table_ids" {
  value = ["${aws_route_table.public.id}", "${aws_route_table.private.*.id}"]
}
