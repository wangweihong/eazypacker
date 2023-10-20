# packer块包含Packer配置，包括指定Packer的版本
packer {
  # required_plugins块指定当前模板构建镜像依赖的插件
  required_plugins {
    alicloud = {
      source  = "github.com/hashicorp/alicloud"
      version = "~> 1"
    }
  }
}


source "alicloud-ecs" "vm" {
  access_key                  = "${var.access_key}"
  image_name                  = "packer_basic_{{timestamp}}"
  instance_type               = "${var.instance_type}"
  internet_charge_type        = "${var.internet_charge_type}"
  io_optimized                = "${var.io_optimized}"
  region                      = "${var.region}"
  secret_key                  = "${var.secret_key}"
  source_image                = "${var.source_image}"
  image_family                = "${var.image_family}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  run_tags                    = "${var.run_tag}"
  # connector
  ssh_username = "${var.ssh_username}"
}

build {
  sources = ["source.alicloud-ecs.vm"]

  provisioner "shell" {
    inline = ["sleep 30", "yum install redis.x86_64 -y"]
  }

}
