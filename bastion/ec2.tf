resource "aws_instance" "bastion" {

  ami                         = "${var.ec2_ami_id}"
  instance_type               = "${var.ec2_instance}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.ec2_subnet_id}"
  private_ip                  = "${var.ec2_private_ip}"
  iam_instance_profile        = "${aws_iam_instance_profile.bastion.id}"
  vpc_security_group_ids      = ["${var.ec2_security_groups}"]
  user_data                   = "${data.template_cloudinit_config.bastion_config.rendered}"
  associate_public_ip_address = "${var.ec2_associate_public_ip}"
  disable_api_termination     = "${var.ec2_disable_api_termination}"
  ebs_optimized               = "${var.ec2_ebs_optimized}"
  monitoring                  = true

  lifecycle {
    ignore_changes = ["user_data"]
  }

  root_block_device {
    delete_on_termination  = true
    volume_type            = "gp2"
    volume_size            = "${var.ec2_ebs_root_size}"
    delete_on_termination  = true
  }

  tags {
    Name                   = "${var.prefix}-${var.name}"
    Terraform              = "Terraform"
    Created                = "${var.owner}"
  }
}

#resource "aws_eip" "bastion_ip" {
#  instance  = "${aws_instance.bastion.id}"
#  vpc       = true
#}

################################################################################
module "common" {
  source  = "../common/"
}


data "template_cloudinit_config" "bastion_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/part-handler"
    content      = "${file("${path.module}/scripts/cloud-init.yml")}"
  }

  part {
    filename     = "01-docker-init.sh"
    content_type = "text/x-shellscript"
    content      = "${module.common.docker-init}"
  }

  part {
    filename     = "02-openvpn-install.sh"
    content_type = "text/x-shellscript"
    content      = "${module.common.openvpn-init}"
  }

  part {
    filename     = "03-custom-metrics.sh"
    content_type = "text/x-shellscript"
    content      = "${module.common.custom-metrics}"
  }
}
