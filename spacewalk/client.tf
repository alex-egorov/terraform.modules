################################### TEST CLIENT #################################
#resource "aws_instance" "spacewalk_client" {
# count = 0
# ami = "${data.aws_ami.centos7.id}"
# instance_type = "t2.medium"
# key_name = "${var.key_name}"
#
# subnet_id = "${data.terraform_remote_state.vpc.app_subnets.0}"
# #private_ip = "${cidrhost(data.terraform_remote_state.vpc.app_subnets.0, 1)}"
#
# #iam_instance_profile = "${aws_iam_instance_profile.bamboo.id}"
# vpc_security_group_ids = ["${data.terraform_remote_state.sg.app}", "${aws_security_group.spacewalk.id}"]
#
# user_data  = "${data.template_cloudinit_config.spacewalk-client.rendered}"
# #user_data = "${file("spacewalk/client.sh")}"
#
# associate_public_ip_address = false
# disable_api_termination     = false     # !!! change to true in production
#
# monitoring  = true
#
# root_block_device {
#   delete_on_termination = true
#   #volume_type = "gp2"
#   volume_size = 8
#   delete_on_termination = true
# }
#
# tags {
#     Name = "${var.name}-spacewalk_client-${count.index}"
#     Terraform = "Terraform"
#     Created   = "${var.owner}"
# }
#}
#
#output "spacewalk-client" {
#  value = "${aws_instance.spacewalk_client.private_ip}"
#}
#
#data "template_cloudinit_config" "spacewalk-client" {
#  gzip          = true
#  base64_encode = true
#
#  part {
#    content_type = "text/part-handler"
#    content      = "${file("spacewalk/spacewalk-client.yml")}"
#  }
#
#  part {
#    filename     = "spacewalk-client.sh"
#    content_type = "text/x-shellscript"
#    content      = "${file("spacewalk/spacewalk-client.sh")}"
#  }
#
#}
