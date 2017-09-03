################################### INSTANCE  ##################################

resource "aws_instance" "spacewalk" {
 ami = "${var.ec2_ami_id}"
 instance_type = "${var.ec2_instance}"
 key_name = "${var.key_name}"

 subnet_id = "${var.ec2_subnet_id}"
 private_ip = "${var.ec2_private_ip}"

 iam_instance_profile = "${aws_iam_instance_profile.spacewalk.id}"
 vpc_security_group_ids = ["${var.ec2_security_groups}", "${aws_security_group.spacewalk.id}"]

 user_data  = "${data.template_cloudinit_config.spacewalk-config.rendered}"

 associate_public_ip_address = "${var.ec2_associate_public_ip}"
 disable_api_termination     = "${var.ec2_disable_api_termination}"

 monitoring  = true

 root_block_device {
   delete_on_termination = true
   volume_type = "gp2"
   volume_size = "${var.ec2_ebs_root_size}"
   delete_on_termination = true
 }

 tags {
     Name = "${var.prefix}-${var.name}"
     Terraform = "Terraform"
     Created   = "${var.owner}"
 }
}

output "spacewalk-instance" {
  value = "${aws_instance.spacewalk.private_ip}"
}

################################### EXTRA VOLUME ###############################
resource "aws_ebs_volume" "spacewalk_ebs_2" {
  availability_zone = "${aws_instance.spacewalk.availability_zone}"
  size              = "${var.ec2_ebs_storage_size}"

  tags {
    Name      = "${var.prefix}-${var.name}-ebs_2"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

resource "aws_volume_attachment" "spacewalk_ebs_2_attach" {
  device_name   = "/dev/xvdb"
  volume_id     = "${aws_ebs_volume.spacewalk_ebs_2.id}"
  instance_id   = "${aws_instance.spacewalk.id}"
  force_detach  = true
  skip_destroy  = false   #!!! set to true in production
}

################################## CLOUD-INIT ##################################


module "lvm" {
  source  = "../lvm/"

  device = "/dev/xvdb"
  vgname = "data"
  lvname = "nexus"
  mountp = "${var.ec2_mount_point}"
}

module "common" {
  source  = "../common/"
}



data "template_cloudinit_config" "spacewalk-config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "01-system.sh"
    content_type = "text/x-shellscript"
    content      = "${module.common.system}"
  }

  part {
    filename     = "02-lvm.sh"
    content_type = "text/x-shellscript"
    content      = "${module.lvm.lvm-init}"
  }

  part {
    filename     = "03-custom-metrics.sh"
    content_type = "text/x-shellscript"
    content      = "${module.common.custom-metrics}"
  }

  part {
    filename     = "04-spacewalk-install.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.spacewalk-install.rendered}"
  }
}

data "template_file" "spacewalk-install" {
    template = "${file("${path.module}/scripts/spacewalk-install.sh.tpl")}"
    vars {
      "version"     = "${var.ec2_version}"
      "hostname"    = "${var.ec2_hostname}"
      "mountp"      = "${var.ec2_mount_point}"
      "db_password" = "${random_id.password.b64}"
      "organization"= "${var.organization}"
      "city"        = "${var.city}"
      "state"       = "${var.state}"
      "country"     = "${var.country}"
    }
}
