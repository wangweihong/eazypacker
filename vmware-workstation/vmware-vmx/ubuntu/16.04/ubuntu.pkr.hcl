packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "output_dir" {
  type    = string
  default = ""
}


variable "source_path" {
  type    = string
  default = ""
}

variable "user" {
  type    = string
  default = "wwhvw"
}

variable "password" {
  type    = string
  default = "wwhvw"
}

//将时间戳转换成20200301时间格式
locals {
  timestamp = formatdate("YYYYMMDD", timestamp())
}


source "vmware-vmx" "ubuntu-16-04" {
  # 这里指定的是输出文件的名字
  vm_name = "${source.name}-${source.type}-${local.timestamp}"
  # 源镜像路径
  source_path = "${var.source_path}"
  # 输出格式,默认为vmx.
  # 注意如果是ova必须安装ovftool工具,且ovftool程序在系统PATH路径上
  #format = "ova"
  # 是否采用连接克隆. 默认是完全克隆
  linked           = false
  ssh_username     = "${var.user}"
  ssh_password     = "${var.password}"
  shutdown_command = "echo ${var.password} | sudo -S shutdown -P now"
  # 设置虚拟磁盘类型。0表示保存到同一个文件
  disk_type_id     = 0
  # vmx 配置https://sanbarrow.com/vmx/vmx-network.html
  vmx_data = {
    # 设置虚拟机启动时连接网卡
    "ethernet0.startConnected" : "true",
    "ethernet0.addressType" : "generated",
    "ethernet0.virtualDev" : "e1000",
    "ethernet0.present" : "TRUE",
    "ethernet0.connectionType" : "nat",
    # 指定网卡编号为ens33
    "ethernet0.pcislotnumber" :"33"
  }
  # https://github.com/hashicorp/packer/issues/7026
  display_name     = "${source.name}-${source.type}-${local.timestamp}"
  output_directory = "${var.output_dir}builds/${source.name}-${source.type}-${local.timestamp}"
}

build {
  sources = ["sources.vmware-vmx.ubuntu-16-04"]
  # 定义一个`shell`配置器
  provisioner "shell" {
    inline = [
      "echo ${var.password} | sudo -S apt-get update",
      "echo ${var.password} | sudo -S apt install -y git",
    ]
  }
}

