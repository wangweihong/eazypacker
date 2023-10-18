packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

//将时间戳转换成20200301时间格式
locals {
  timestamp = formatdate("YYYYMMDD", timestamp())
}

variable "ami_prefix" {
  type    = string
  default = "ami-ubuntu-16.04"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "disk_size" {
  type    = string
  default = "40960"
}

variable "iso_urls" {
  type = list(string)
  # 先从本地路径iso/查找iso,如果不存在再去指定URL下载
  default = [
    "iso/ubuntu-16.04.4-server-amd64.iso",
    "https://old-releases.ubuntu.com/releases/16.04.4/ubuntu-16.04-server-amd64.iso"
  ]
}

variable "output_dir" {
  type    = string
  default = ""
}

variable "iso_checksum" {
  type = string
  # 也可以指定从某个文件中读取"file:./shasums.txt"
  default = "b8b172cbdf04f5ff8adc8c2c1b4007ccf66f00fc6a324a6da6eba67de71746f6"
}

variable "user" {
  type    = string
  default = "wwhvw"
}

variable "password" {
  type    = string
  default = "wwhvw"
}


source "vmware-iso" "ubuntu-16-04" {
  # <bs>等为模拟键盘执行删除操作,删除原来的boot命令
  # net.ifnames=0为内核参数禁止可预测的网络接口重命名行为。不能设置该参数, 会导致使用默认网卡eth0，而不是ens33。从而导致网卡一直无法启动
  boot_command = [
    "<enter><wait>",
    "<f6><esc>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs>",
    "/install/vmlinuz ",
    "initrd=/install/initrd.gz ",
    #   "net.ifnames=0 ",
    "auto-install/enable=true ",
    "debconf/priority=critical ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "<enter>"
  ]
  # 定义当vm启动并输入引导命令时Packer等待的时间
  boot_wait = "5s"
  # 指定当vm安装好系统后packer连接vm的方式。linux一般是ssh, windows一般是winrm.
  communicator = "ssh"
  vm_name      = "${source.name}-${source.type}-${var.disk_size}M-${local.timestamp}"
  cpus         = "${var.cpus}"
  memory       = "${var.memory}"
  # 磁盘大小,单位为MB
  disk_size    = "${var.disk_size}"
  iso_urls     = "${var.iso_urls}"
  iso_checksum = "${var.iso_checksum}"
  headless     = false
  # 如果设置, packer将会启动并设置服务http_directory指定的目录且随机端口的http服务
  # builder可以通过类似于`wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/foo/bar/preseed.cfg`来使用该目录
  http_directory = "preseed"
  # 安装系统后连接到虚拟机上的ssh账号,必须要preseed.cfg保持一致
  ssh_username         = "${var.user}"
  ssh_password         = "${var.password}"
  ssh_port             = 22
  ssh_timeout          = "3600s"
  vnc_disable_password = true
  vnc_bind_address     = "127.0.0.1"
  # vmx 配置https://sanbarrow.com/vmx/vmx-network.html
  # 设置虚拟机启动时连接网卡
  vmx_data = {
    "ethernet0.startConnected" : "true",
    "ethernet0.addressType" : "generated",
    "ethernet0.virtualDev" : "e1000"
    "ethernet0.present" : "TRUE"
  }
  # 设置虚拟磁盘类型。0表示保存到同一个文件
  disk_type_id = 0
  # 安装完系统后删除网卡, 否则所有基于该镜像创建出来的虚拟机都会使用同样IP
  vmx_remove_ethernet_interfaces = true
  output_directory = "${var.output_dir}builds/${source.name}-${source.type}-${var.disk_size}M-${local.timestamp}"
  shutdown_command = "echo ${var.password} | sudo -S shutdown -P now"
}

build {
  sources = ["sources.vmware-iso.ubuntu-16-04"]
}
