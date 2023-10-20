locals {

  /* ----------- vmware -----------*/
  vmware_tools_upload_flavor = var.vmware_tools_upload_flavor == null ? (
    var.is_windows ? "windows" : "linux"
  ) : var.vmware_tools_upload_flavor
  vmware_tools_upload_path = var.vmware_tools_upload_path == null ? (
    var.is_windows ? "c:\\vmware-tools.iso" : "/tmp/vmware-tools.iso"
  ) : var.vmware_tools_upload_path
  vmware_vmx_display_name = var.vmware_vmx_display_name == null ? (
    var.os_arch == "x86_64" ? "vmx-${var.os_name}-${var.os_version}-amd64" : "vmx-${var.os_name}-${var.os_version}-${var.os_arch}"
  ) : var.vmware_vmx_display_name
  /*------------ vmware-vmx ----------*/
  //可以直接设置镜像路径，或者设置镜像目录和镜像名拼接成路径
  vmware_vmx_source_file_format = var.vmware_vmx_source_file_format == null ? "vmx" : var.vmware_vmx_source_file_format
  vmware_vmx_source_directory = var.vmware_vmx_source_directory == null ? "${local.output_directory}-vmware-iso" : var.vmware_vmx_source_directory
  vmware_vmx_source_file_name = var.vmware_vmx_source_file_name == null ? "${local.vm_name}" : var.vmware_vmx_source_file_name
  vmware_vmx_source_path      = var.vmware_vmx_source_path == null ? "${local.vmware_vmx_source_directory}/${local.vmware_vmx_source_file_name}.${local.vmware_vmx_source_file_format}" : var.vmware_vmx_source
  /* --------- Source块 ------------*/
  default_boot_wait = var.default_boot_wait == null ? (
    var.is_windows ? "60s" : "5s"
  ) : var.default_boot_wait
  cd_files = var.cd_files == null ? (
    var.is_windows ? (
      var.hyperv_generation == 2 ? [
        "${path.root}/win_answer_files/${var.os_version}/hyperv-gen2/Autounattend.xml",
        ] : [
        "${path.root}/win_answer_files/${var.os_version}/Autounattend.xml",
      ]
    ) : null
  ) : var.cd_files
  communicator = var.communicator == null ? (
    var.is_windows ? "winrm" : "ssh"
  ) : var.communicator
  floppy_files = var.floppy_files == null ? (
    var.is_windows ? [
      "${path.root}/win_answer_files/${var.os_version}/Autounattend.xml",
      ] : (
      var.os_name == "springdalelinux" ? [
        "${path.root}/http/rhel/${substr(var.os_version, 0, 1)}ks.cfg"
      ] : null
    )
  ) : var.floppy_files
  http_directory   = var.http_directory == null ? "${path.root}/http" : var.http_directory
  memory           = var.memory == null ? (var.is_windows ? 4096 : 2048) : var.memory
  output_directory = var.output_directory == null ? "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}" : var.output_directory
  shutdown_command = var.shutdown_command == null ? (
    var.is_windows ? "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"" : (
      var.os_name == "freebsd" ? "echo ${var.ssh_password} | su -m root -c 'shutdown -p now'" : "echo ${var.ssh_password} | sudo -S /sbin/halt -h -p"
    )
  ) : var.shutdown_command
  vm_name = var.vm_name == null ? (
    var.os_arch == "x86_64" ? "${var.os_name}-${var.os_version}-amd64" : "${var.os_name}-${var.os_version}-${var.os_arch}"
  ) : var.vm_name
  // use iso_url when iso_urls not set
  iso_url = var.iso_urls == null ? var.iso_url : null
  /*----------------自定义---------------*/
  timestamp = formatdate("YYYYMMDD", timestamp())
}

//////////////////////////////// 
source "vmware-iso" "vm" {
  /*------------- 插件特定选项 ------------ */
  vmx_data                       = var.vmware_vmx_data
  disk_type_id                   = var.vmware_disk_type_id
  vmx_remove_ethernet_interfaces = var.vmware_vmx_remove_ethernet_interfaces
  vnc_disable_password           = var.vmware_vnc_disable_password
  vnc_bind_address               = var.vmware_vnc_bind_address
  /*----------- Source块通用参数 ---------- */
  boot_command     = var.boot_command
  boot_wait        = var.vmware_boot_wait == null ? local.default_boot_wait : var.vmware_boot_wait
  cpus             = var.cpus
  memory           = local.memory
  disk_size        = var.disk_size
  headless         = var.headless
  cd_files         = local.cd_files
  floppy_files     = local.floppy_files
  iso_checksum     = var.iso_checksum
  iso_url          = local.iso_url
  iso_urls         = var.iso_urls
  http_directory   = local.http_directory
  output_directory = "${local.output_directory}-${source.type}"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  communicator     = local.communicator
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}


source "vmware-vmx" "vm" {
  /*------------- 插件特定选项 ------------ */
  vmx_data                       = var.vmware_vmx_data
  disk_type_id                   = var.vmware_disk_type_id
  vmx_remove_ethernet_interfaces = var.vmware_vmx_remove_ethernet_interfaces
  vnc_disable_password           = var.vmware_vnc_disable_password
  vnc_bind_address               = var.vmware_vnc_bind_address
  linked                         = var.vmware_vmx_linked
  source_path                    = local.vmware_vmx_source_path
  /*----------- Source块通用参数 ---------- */

  output_directory = "${local.output_directory}-${source.type}"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  display_name     = local.vmware_vmx_display_name
  communicator     = local.communicator
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  vm_name          = local.vm_name
}


source "alicloud-ecs" "vm" {
  /*------------- 插件特定选项 ------------ */
  access_key                  = var.alicloud_access_key
  secret_key                  = var.alicloud_secret_key
  instance_type               = var.alicloud_instance_type
  internet_charge_type        = var.alicloud_internet_charge_type
  io_optimized                = var.alicloud_io_optimized
  region                      = var.alicloud_region
  image_family                = var.alicloud_image_family
  source_image                = var.alicloud_source_image
  image_name                  = local.vm_name
  associate_public_ip_address = var.alicloud_vm_associate_public_ip_address
  run_tags = var.alicloud_run_tags == null ? ({
    "Built by"   = "Packer"
    "Managed by" = "Packer"
  }) : var.alicloud_run_tags
  description = var.alicloud_description
  /*----------- Source块通用参数 ---------- */
  ssh_username = var.ssh_username
}