variable "build_name" {
  type    = string
  default = "centos-7"
}

//将时间戳转换成20200301时间格式
locals {
  timestamp = formatdate("YYYYMMDD", timestamp())
}

# 注意image_family和source_image二选一
# 阿里云镜像版本会一直更新, 最好采用image_family而不是source_image
variable "image_family" {
  type    = string
  default = "acs:centos_7_9_x64"
}

# 使用指定的阿里云基础镜像
variable "source_image" {
  type = string
  # default = "centos_7_9_x64_20G_alibase_20230919.vhd"
  default = ""
}

variable "ssh_username" {
  type    = string
  default = "root"
}