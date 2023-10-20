locals {
  /* ----------- virtualbox-iso ------------------*/
  virtualbox_gfx_controller = var.virtualbox_gfx_controller == null ? (
    var.is_windows ? "vboxsvga" : "vmsvga"
  ) : var.virtualbox_gfx_controller
  virtualbox_gfx_vram_size = var.virtualbox_gfx_controller == null ? (
    var.is_windows ? 128 : 33
  ) : var.virtualbox_gfx_vram_size
  virtualbox_guest_additions_mode = var.virtualbox_guest_additions_mode == null ? (
    var.is_windows ? "attach" : "upload"
  ) : var.virtualbox_guest_additions_mode
  /* ----------- qemu ----------------------------*/
  # qemu
  qemu_binary = var.qemu_binary == null ? "qemu-system-${var.os_arch}" : var.qemu_binary
  qemu_machine_type = var.qemu_machine_type == null ? (
    var.os_arch == "aarch64" ? "virt" : "q35"
  ) : var.qemu_machine_type
  qemu_args = var.qemu_args == null ? (
    var.is_windows ? [
      ["-drive", "file=${path.root}/win_answer_files/virtio-win.iso,media=cdrom,index=3"],
      ["-drive", "file=${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-qemu/{{ .Name }},if=virtio,cache=writeback,discard=ignore,format=qcow2,index=1"],
      ] : (
      var.os_arch == "aarch64" ? [
        ["-boot", "strict=off"]
      ] : null
    )
  ) : var.qemu_args

  /* ----------- hyperv-iso ----------------------*/
  hyperv_enable_dynamic_memory = var.hyperv_enable_dynamic_memory == null ? (
    var.hyperv_generation == 2 && var.is_windows ? "true" : null
  ) : var.hyperv_enable_dynamic_memory
  hyperv_enable_secure_boot = var.hyperv_enable_secure_boot == null ? (
    var.hyperv_generation == 2 && var.is_windows ? false : null
  ) : var.hyperv_enable_secure_boot

  /* ----------- parallels-iso -----------*/
  parallels_tools_flavor = var.parallels_tools_flavor == null ? (
    var.is_windows ? (
      var.os_arch == "x86_64" ? "win" : "win-arm"
      ) : (
      var.os_arch == "x86_64" ? "lin" : "lin-arm"
    )
  ) : var.parallels_tools_flavor
  parallels_tools_mode = var.parallels_tools_mode == null ? (
    var.is_windows ? "attach" : "upload"
  ) : var.parallels_tools_mode
  parallels_prlctl = var.parallels_prlctl == null ? (
    var.is_windows ? [
      ["set", "{{ .Name }}", "--efi-boot", "off"]
      ] : [
      ["set", "{{ .Name }}", "--3d-accelerate", "off"],
      ["set", "{{ .Name }}", "--videosize", "16"]
    ]
  ) : var.parallels_prlctl
  /* ----------- vmware通用变量 -----------*/
  vmware_tools_upload_flavor = var.vmware_tools_upload_flavor == null ? (
    var.is_windows ? "windows" : "linux"
  ) : var.vmware_tools_upload_flavor
  vmware_tools_upload_path = var.vmware_tools_upload_path == null ? (
    var.is_windows ? "c:\\vmware-tools.iso" : "/tmp/vmware-tools.iso"
  ) : var.vmware_tools_upload_path
  vmware_vmx_display_name = var.vmware_vmx_display_name == null ? (
    var.os_arch == "x86_64" ? "vmx-${var.os_name}-${var.os_version}-amd64" : "vmx-${var.os_name}-${var.os_version}-${var.os_arch}"
  ) : var.vmware_vmx_display_name
  vmware_vmdk_name = var.vmware_vmdk_name == null ? local.vm_name : var.vmware_vmdk_name
  /*------------ vmware-vmx ----------*/
  //可以直接设置镜像路径，或者设置镜像目录和镜像名拼接成路径
  vmware_vmx_source_file_format = var.vmware_vmx_source_file_format == null ? "vmx" : var.vmware_vmx_source_file_format
  vmware_vmx_source_directory   = var.vmware_vmx_source_directory == null ? "${local.output_directory}/vmware-iso" : var.vmware_vmx_source_directory
  vmware_vmx_source_file_name   = var.vmware_vmx_source_file_name == null ? "${local.vm_name}" : var.vmware_vmx_source_file_name
  vmware_vmx_source_path        = var.vmware_vmx_source_path == null ? "${local.vmware_vmx_source_directory}/${local.vmware_vmx_source_file_name}.${local.vmware_vmx_source_file_format}" : var.vmware_vmx_source
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
  output_directory = var.output_directory == null ? "${path.root}/../builds/packer/${var.os_name}/${var.os_version}/${var.os_arch}" : "${var.output_directory}/${var.os_name}/${var.os_version}/${var.os_arch}"
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
  vmdk_name                      = local.vmware_vmdk_name
  cdrom_adapter_type             = var.vmware_cdrom_adapter_type
  disk_adapter_type              = var.vmware_disk_adapter_type // 安装windows系统时必须设置这个值.
  guest_os_type                  = var.vmware_guest_os_type
  network                        = var.vmware_network
  network_adapter_type           = var.vmware_network_adapter_type
  usb                            = var.vmware_enable_usb
  tools_upload_flavor            = local.vmware_tools_upload_flavor // windows这里貌似有bug,会阻塞在上传vmware-iso
  tools_upload_path              = local.vmware_tools_upload_path
  version                        = var.vmware_version
  format                         = var.vmware_format

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
  output_directory = "${local.output_directory}/${source.type}"
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


# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hyperv-iso" "vm" {
  # Hyper-v specific options
  enable_dynamic_memory = local.hyperv_enable_dynamic_memory
  enable_secure_boot    = local.hyperv_enable_secure_boot
  generation            = var.hyperv_generation
  guest_additions_mode  = var.hyperv_guest_additions_mode
  switch_name           = var.hyperv_switch_name
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.hyperv_boot_wait == null ? local.default_boot_wait : var.hyperv_boot_wait
  cd_files         = var.hyperv_generation == 2 ? local.cd_files : null
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = var.hyperv_generation == 2 ? null : local.floppy_files
  headless         = var.headless
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_urls         = var.iso_urls
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${local.output_directory}/${source.type}"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}

source "virtualbox-iso" "vm" {
  # Virtualbox specific options
  gfx_controller            = local.virtualbox_gfx_controller
  gfx_vram_size             = local.virtualbox_gfx_vram_size
  guest_additions_path      = var.virtualbox_guest_additions_path
  guest_additions_mode      = local.virtualbox_guest_additions_mode
  guest_additions_interface = var.virtualbox_guest_additions_interface
  guest_os_type             = var.virtualbox_guest_os_type
  hard_drive_interface      = var.virtualbox_hard_drive_interface
  iso_interface             = var.virtualbox_iso_interface
  vboxmanage                = var.virtualbox_manage
  virtualbox_version_file   = var.virtualbox_version_file
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.virtualbox_boot_wait == null ? local.default_boot_wait : var.virtualbox_boot_wait
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = local.floppy_files
  headless         = var.headless
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  iso_urls         = var.iso_urls
  memory           = local.memory
  output_directory = "${local.output_directory}/${source.type}"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}

source "parallels-iso" "vm" {
  # Parallels specific options
  guest_os_type          = var.parallels_guest_os_type
  parallels_tools_flavor = local.parallels_tools_flavor
  parallels_tools_mode   = local.parallels_tools_mode
  prlctl                 = local.parallels_prlctl
  prlctl_version_file    = var.parallels_prlctl_version_file
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.parallels_boot_wait == null ? local.default_boot_wait : var.parallels_boot_wait
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = local.floppy_files
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  iso_urls         = var.iso_urls
  memory           = local.memory
  output_directory = "${local.output_directory}/${source.type}"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}

source "qemu" "vm" {
  # QEMU specific options
  accelerator  = var.qemu_accelerator
  display      = var.headless ? "none" : var.qemu_display
  machine_type = local.qemu_machine_type
  qemu_binary  = local.qemu_binary
  qemuargs     = local.qemu_args
  format       = var.qemu_format
  disk_image   = var.qemu_disk_image
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.qemu_boot_wait == null ? local.default_boot_wait : var.qemu_boot_wait
  cd_files         = local.cd_files
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = local.floppy_files
  headless         = var.headless
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  iso_urls         = var.iso_urls
  memory           = local.memory
  output_directory = "${local.output_directory}/${source.type}"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}

///////////////////////////////////

source "vmware-vmx" "vm" {
  /*------------- 插件特定选项 ------------ */
  vmx_data                       = var.vmware_vmx_data
  disk_type_id                   = var.vmware_disk_type_id
  vmx_remove_ethernet_interfaces = var.vmware_vmx_remove_ethernet_interfaces
  vnc_disable_password           = var.vmware_vnc_disable_password
  vnc_bind_address               = var.vmware_vnc_bind_address
  linked                         = var.vmware_vmx_linked
  source_path                    = local.vmware_vmx_source_path
  vmdk_name                      = local.vmware_vmdk_name
  format                         = var.vmware_format
  /*----------- Source块通用参数 ---------- */

  output_directory = "${local.output_directory}/${source.type}"
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
  image_encrypted             = var.alicloud_image_encrypted
  ssh_private_ip              = var.alicloud_ssh_private_ip
  associate_public_ip_address = var.alicloud_vm_associate_public_ip_address
  run_tags = var.alicloud_run_tags == null ? ({
    "Built by"   = "Packer"
    "Managed by" = "Packer"
  }) : var.alicloud_run_tags
  description = var.alicloud_description
  /*----------- Source块通用参数 ---------- */
  ssh_username = var.alicloud_ssh_user
}