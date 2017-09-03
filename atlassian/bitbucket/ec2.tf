####################### BITBUCKET-SERVER INSTANCE #################################

resource "aws_instance" "bitbucket" {
 ami                         = "${var.ec2_ami_id}"
 instance_type               = "${var.ec2_instance}"
 key_name                    = "${var.key_name}"
 subnet_id                   = "${var.ec2_subnet_id}"
 private_ip                  = "${var.ec2_private_ip}"
 iam_instance_profile        = "${aws_iam_instance_profile.bitbucket.id}"
 vpc_security_group_ids      = ["${var.ec2_security_groups}", "${aws_security_group.bitbucket.id}"]
 user_data                   = "${data.template_cloudinit_config.bitbucket_config.rendered}"
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

output "bitbucket-instance" {
  value = "${aws_instance.bitbucket.private_ip}"
}

################################## CLOUD-INIT ##################################

module "lvm" {
  source  = "../../lvm/"

  device = "/dev/xvdb"
  vgname = "data"
  lvname = "nexus"
  mountp = "${var.ec2_mount_point}"
}

module "common" {
  source  = "../../common/"
}


data "template_cloudinit_config" "bitbucket_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "01-docker-init.sh"
    content_type = "text/x-shellscript"
    content      = "${module.common.docker-init}"
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
    filename     = "04-bitbucket-install.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.bitbucket-install.rendered}"
  }


}

data "template_file" "bitbucket-install" {
    template = "${file("${path.module}/scripts/bitbucket-install.sh.tpl")}"
    vars {
      "version"     = "${var.ec2_version}"
      "hostname"    = "${var.ec2_hostname}"
      "db_host"     = "${aws_db_instance.bitbucket.endpoint}"
      "db_name"     = "${var.db_name}"
      "db_user"     = "${var.db_username}"
      "db_password" = "${var.db_password}"
      "mountp"      = "${var.ec2_mount_point}"
    }
}


################################### EXTRA VOLUME ###############################
resource "aws_ebs_volume" "bitbucket_ebs_2" {
  availability_zone = "${aws_instance.bitbucket.availability_zone}"
  size              = "${var.ec2_ebs_storage_size}"

  tags {
    Name      = "${var.name}-bitbucket-ebs_2"
    Terraform = "Terraform"
    Created   = "${var.owner}"
  }
}

resource "aws_volume_attachment" "bitbucket_ebs_2_attach" {
  device_name   = "/dev/xvdb"
  volume_id     = "${aws_ebs_volume.bitbucket_ebs_2.id}"
  instance_id   = "${aws_instance.bitbucket.id}"
  force_detach  = true
  skip_destroy  = false   #!!! set to true in production
}

#resource "aws_ebs_volume" "bitbucket_ebs_3" {
#  availability_zone = "${aws_instance.bitbucket.availability_zone}"
#  size = 50
#   tags {
#     Name = "${var.name}-bitbucket-ebs_3"
#     Terraform = "Terraform"
#     Created   = "${var.owner}"
#   }
#}
#
#resource "aws_volume_attachment" "bitbucket_ebs_3_attach" {
#  device_name = "/dev/xvdc"
#  volume_id = "${aws_ebs_volume.bitbucket_ebs_3.id}"
#  instance_id = "${aws_instance.bitbucket.id}"
#}
