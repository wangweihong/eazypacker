
variable "access_key" {
  type    = string
  default = "${env("ALICLOUD_ACCESS_KEY")}"
}

variable "secret_key" {
  type    = string
  default = "${env("ALICLOUD_SECRET_KEY")}"
}

variable "region" {
  type    = string
  default = "cn-shenzhen"
}

variable "instance_type" {
  type    = string
  default = "ecs.t5-lc1m1.small"
}

variable "io_optimized" {
  type    = boolean
  default = "true"
}

variable "internet_charge_type" {
  type    = string
  default = "PayByTraffic"
}

variable "run_tag" {
  type = map(string)
  default = {
    "Built by"   = "Packer"
    "Managed by" = "Packer"
  }
}

# 必须要设置外网IP,否则实例构建后无法通过ssh连接执行provisioner操作。
variable "associate_public_ip_address" {
  type    = boolean
  default = true
}