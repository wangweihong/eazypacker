packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

variable "name" {
  type    = string
  default = "ubuntu2304"
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
    "iso/ubuntu-20.04.1-live-server-amd64.iso",
    "https://releases.ubuntu.com/focal/ubuntu-20.04.1-live-server-amd64.iso"
  ]
}

variable "iso_checksum" {
  type = string
  # 也可以指定从某个文件中读取"file:./shasums.txt"
  default = "c7cda48494a6d7d9665964388a3fc9c824b3bef0c9ea3818a1be982bc80d346b"
}

locals{
  timestamp = formatdate(timestamp(),"YYYYMMDD" )
}

source "vmware-iso" "basic-example" {
  # <esc><esc><enter><wait>: 模拟按下Enter键，以选择引导菜单中的默认项。
  # 第二段为Kickstart引导命令，它指定了Kickstart文件的位置以及一些参数，如语言、键盘布局、主机名等。
  # `url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-preseed.cfg`: 这部分指定了Kickstart文件的位置，
  #    其中`{{ .HTTPIP }}`和`{{ .HTTPPort }}`是Packer在HTTP服务器上提供的信息。
  # `initrd=/install/initrd.gz -- <enter>`: 模拟按下Enter键以继续引导过程。
  boot_command = [
    "<enter><enter><f6><esc><wait> ",
    "autoinstall ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter><wait>"
  ]
  # 定义当vm启动并输入引导命令时Packer等待的时间
  boot_wait = "5s"
  # 指定当vm安装好系统后packer连接vm的方式。linux一般是ssh, windows一般是winrm.
  communicator = "ssh"
  vm_name      = "packer-${var.name}"
  cpus         = "${var.cpus}"
  memory       = "${var.memory}"
  # 磁盘大小,单位为MB
  disk_size    = "${var.disk_size}"
  iso_urls     = "${var.iso_urls}"
  iso_checksum = "${var.iso_checksum}"
  headless     = false
  # 如果设置, packer将会启动并设置服务http_directory指定的目录且随机端口的http服务
  # builder可以通过类似于`wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/foo/bar/preseed.cfg`来使用该目录
  http_directory       = "preseed"
  ssh_username         = "wwhvw"
  ssh_password         = "wwhvw"
  ssh_port             = 22
  ssh_timeout          = "3600s"
  vnc_disable_password = true
  vnc_bind_address     = "127.0.0.1"
  output_directory     = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command     = "sudo -S shutdown -P now"
}

build {
  sources = ["sources.vmware-iso.basic-example"]
}
