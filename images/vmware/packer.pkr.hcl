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


source "vmware-iso" "base-image" {
  // 硬件
  vm_name                        = "${source.name}-${source.type}-${var.disk_size}M-${local.timestamp}"
  cpus                           = "${var.cpus}"
  memory                         = "${var.memory}"
  disk_size                      = "${var.disk_size}"
  vmx_data                       = "${var.vmx_data}"
  disk_type_id                   = "${var.disk_type_id}"
  vmx_remove_ethernet_interfaces = "${var.vmx_remove_ethernet_interfaces}"
  headless                       = "${var.headless}"
  vnc_disable_password           = "${var.vnc_disable_password}"
  vnc_bind_address               = "${var.vnc_bind_address}"

  // 通用
  ssh_port = "${var.ssh_port}"
  // ssh_timeout      = "${var.ssh_timeout}"
  ssh_timeout      = var.ssh_timeout
  output_directory = "${var.output_dir}builds/${source.name}-${source.type}-${var.disk_size}M-${local.timestamp}"
  communicator     = "${var.communicator}"
  ssh_username     = "${var.user}"
  ssh_password     = "${var.password}"
  http_directory   = "${var.http_directory}"

  // 系统
  // shutdown_command    = "echo ${var.password} | sudo -S shutdown -P now"
  shutdown_command = "${var.shutdown_command}"
  boot_command     = "${var.boot_command}"
  boot_wait        = "${var.boot_wait}"
  iso_urls         = "${var.iso_urls}"
  iso_checksum     = "${var.iso_checksum}"
}

build {
  sources = ["sources.vmware-iso.base-image"]
}
