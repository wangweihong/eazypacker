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
  default = "81920"
}

variable "iso_urls" {
  type    = list(string)
  # 先从本地路径iso/查找iso,如果不存在再去指定URL下载
  default = ["iso/ubuntu-23.04-live-server-amd64.iso", "https://releases.ubuntu.com/23.04/ubuntu-23.04-live-server-amd64.iso"]
}

variable "iso_checksum" {
  type    = string
  # 也可以指定从某个文件中读取"file:./shasums.txt"
  default = "c7cda48494a6d7d9665964388a3fc9c824b3bef0c9ea3818a1be982bc80d346b"
}

source "vmware-iso" "basic-example" {
  boot_command = [
    "c",
    "linux /casper/vmlinuz autoinstall net.ifnames=0 biosdevname=0 ",
    "ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' --- <enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  boot_wait    = "5s"
  communicator = "ssh"
  vm_name      = "packer-${var.name}"
  cpus         = "${var.cpus}"
  memory       = "${var.memory}"
  # 磁盘大小,单位为MB
  disk_size    = "${var.disk_size}"
  iso_urls     = "${var.iso_urls}"
  iso_checksum = "${var.iso_checksum}"
  headless             = false
 # http_directory       = "http"
  ssh_username         = "packer"
  ssh_password         = "packer"
  ssh_port             = 22
  ssh_timeout          = "3600s"
  vnc_disable_password = true
  vnc_bind_address     = "127.0.0.1"
  //  vmx_data              = {
  //    "firmware" = "efi"
  //  }
  //  vmx_data_post         = {
  //    "virtualHW.version": "18",
  //    "cleanShutdown": "true",
  //    "softPowerOff": "true",
  //    "ethernet0.virtualDev": "e1000",
  //    "ethernet0.startConnected": "true",
  //    "ethernet0.wakeonpcktrcv": "false"
  //  }
  //  guest_os_type         = "ubuntu-64"
  //  vmx_remove_ethernet_interfaces = true
  //  version               = 18
  //  tools_upload_flavor   = "linux"
  output_directory = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command = "sudo -S shutdown -P now"
}

build {
  sources = ["sources.vmware-iso.basic-example"]
}
