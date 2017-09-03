output "db_endpoint" {
  value = "${aws_db_instance.bitbucket.endpoint}"
}

output "ec2_private_ip" {
  value = "${aws_instance.bitbucket.private_ip}"
}
