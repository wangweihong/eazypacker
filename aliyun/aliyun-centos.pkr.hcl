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

variable "access_key" {
  type    = string
  default = "${env("ALICLOUD_ACCESS_KEY")}"
}

variable "secret_key" {
  type    = string
  default = "${env("ALICLOUD_SECRET_KEY")}"
}

source "alicloud-ecs" "aliyun-test" {
  access_key           = "${var.access_key}"
  image_name           = "packer_basic_{{timestamp}}"
  instance_type        = "ecs.t5-lc1m1.small"
  internet_charge_type = "PayByTraffic"
  io_optimized         = "true"
  region               = "cn-shenzhen"
  secret_key           = "${var.secret_key}"
  #source_image         = "centos_7_9_x64_20G_alibase_20230919.vhd"
  # 阿里云镜像版本会一直更新, 最好采用image_family而不是source_image
  image_family = "acs:centos_7_9_x64"
  # 必须要设置外网IP,否则实例构建后无法通过ssh连接执行provisioner操作。
  associate_public_ip_address = "true"
  run_tags = {
    "Built by"   = "Packer"
    "Managed by" = "Packer"
  }

  ssh_username = "root"
}

build {
  sources = ["source.alicloud-ecs.aliyun-test"]

  provisioner "shell" {
    inline = ["sleep 30", "yum install redis.x86_64 -y"]
  }

}
