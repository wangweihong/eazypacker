/* ----  通用变量 --------*/

variable "os_name" {
  type        = string
  description = "OS Brand Name"
}
variable "os_version" {
  type        = string
  description = "OS version number"
}
variable "os_arch" {
  type = string
  validation {
    condition     = var.os_arch == "x86_64" || var.os_arch == "aarch64"
    error_message = "The OS architecture type should be either x86_64 or aarch64."
  }
  description = "OS architecture type, x86_64 or aarch64"
}

variable "http_proxy" {
  type        = string
  default     = env("http_proxy")
  description = "Http proxy url to connect to the internet"
}

variable "https_proxy" {
  type        = string
  default     = env("https_proxy")
  description = "Https proxy url to connect to the internet"
}

variable "no_proxy" {
  type        = string
  default     = env("no_proxy")
  description = "No Proxy"
}

variable "use_alicloud" {
  type       = string
  default     = env("use_alicloud")
  description = "是否使用阿里云源"
}

variable "golden_image_sources_enabled" {
  type = list(string)
  default = [
    // FIXME: 在windows 10尝试安装ubuntu 16/20均无法无人值守安装. 而且一堆奇怪的问题。先不启用
    "source.hyperv-iso.vm",
    // FIXME: MAC的虚拟化, 无环境测试
    "source.parallels-iso.vm",
    // FIXME： 和hyperv一样问题不少
    "source.virtualbox-iso.vm",
    "source.qemu.vm",
    "source.vmware-iso.vm",
  ]
  description = "从ISO中构建各种操作系统的黄金镜像"
}

variable "custom_image_sources_enabled" {
  type = list(string)
  default = [
    "source.vmware-vmx.vm",
    "source.alicloud-ecs.vm"
  ]
  description = "基于黄金镜像构建各种定制化镜像"
}

variable "is_windows" {
  type        = bool
  default     = false
  description = "Determines to set setting for Windows or Linux"
}

variable "replace_app_source" {
  type        = string
  default     = env("replace_app_source")
  description = "Whether replace app source. such  as apt/yum source"
}

variable "build_version_path" {
  type        = string
  default     = null
  description = "用于记录构建操作系统镜像的代码版本号"
}

variable "is_vagranted" {
  type        = bool
  default     = false
  description = "是否对输出制品构建成vagrant box"
}

variable "vagrant_output_path" {
  type        = string
  default     = null
  description = "vagrant output路径"
}

variable "keep_input_artifact" {
  type        = bool
  default     = false
  description = "post-processors是否保持原制品"
}

variable "release_version" {
  type        = string
  default     = ""
  description = "描述构建版本"
}

variable "build_timestamp" {
  type        = string
  default     = null
  description = "描述制品构建日期"
}

/*----------- 定制相关变量--------------------*/
variable "kubernetes_version" {
  type = string 
  default = "1.18.0"
  description = "定制镜像的kubernetes版本"
}

variable "is_kubernetes_master" {
  type = string 
  description = "当前镜像是否kubernetes主节点。默认为工作节点"
  default     = env("is_kubernetes_master")
}

variable "go_version" {
  type = string 
  default = "1.19.13"
  description = "定制镜像的golang版本"
}


variable "database_type" {
  type = string 
  default = "postgresql"
  description = "数据库"
}

variable "database_version" {
  type = string 
  default = "14"
  description = "数据库版本"
}

variable "pulumi_version" {
  type = string
  default = "3.94.2"
  description = "IaC工具pulumi版本"
}

variable "terraform_version" {
  type = string 
  default = "1.6.4"
  description = "IaC工具terraform版本"
}


variable "harbor_domain" {
  type = string 
  default = "master.harbor.wang"
  description = "harbor域名"
}

variable "harbor_version" {
  type = string 
  default = "2.9.1"
  description = "harbor版本"
}

/*----------- 操作系统通用变量 -------------- */


/* ---------- Source块通用变量 ------------- */
variable "boot_command" {
  type        = list(string)
  default     = null
  description = "Commands to pass to gui session to initiate automated install"
}
variable "default_boot_wait" {
  type    = string
  default = null
}
variable "cd_files" {
  type    = list(string)
  default = null
}
variable "cpus" {
  type    = number
  default = 2
}
variable "communicator" {
  type    = string
  default = null
}
variable "disk_size" {
  type    = number
  default = 65536
}
variable "floppy_files" {
  type    = list(string)
  default = null
}
variable "headless" {
  type        = bool
  default     = false
  description = "Start GUI window to interact with VM. 启用时，将在后台安装系统"
}
variable "http_directory" {
  type    = string
  default = null
}
variable "iso_checksum" {
  type        = string
  default     = null
  description = "ISO download checksum"
}

variable "iso_url" {
  type        = string
  default     = null
  description = "ISO download url"
}

variable "iso_urls" {
  type        = list(string)
  default     = null
  description = "ISO download urls."

  // 可以指定多个. 如果值不是url,则从**当前路径下**/iso/去查找iso,如果不存在再去指定URL下载
  // 特别注意, 指定的路径都是相对路径非绝对路径. 即使设置了"/f/build_cache/ubunut.iso"访问的也是当前路径下/f/build_cache/ 
  // https://github.com/hashicorp/packer/issues/9050
  //  default = [
  //    "iso/ubuntu-16.04.4-server-amd64.iso",
  //    "https://old-releases.ubuntu.com/releases/16.04.4/ubuntu-16.04-server-amd64.iso"
  //  ]
}

variable "memory" {
  type    = number
  default = null
}

variable "shutdown_command" {
  type    = string
  default = null
}
variable "shutdown_timeout" {
  type    = string
  default = "15m"
}

variable "ssh_username" {
  type        = string
  default     = "vagrant"
  description = "通过ssh连接系统的账号密码。如果是通过iso安装, 必须和预设账号密码保持一致"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_port" {
  type    = number
  default = 22
}
variable "ssh_timeout" {
  type    = string
  default = "30m"
}

variable "winrm_username" {
  type    = string
  default = "vagrant"
}

variable "winrm_password" {
  type        = string
  default     = "vagrant"
  description = "如果是通过iso安装, 必须和预设账号密码保持一致"
}
variable "winrm_timeout" {
  type    = string
  default = "60m"
}

variable "vm_name" {
  type        = string
  default     = null
  description = ""
}


variable "output_directory" {
  type        = string
  default     = null
  description = "镜像数据输出目录"
}


/* --------- Build块通用变量 -------------- */
// 指定provisioner运行的脚本
variable "scripts" {
  type        = list(string)
  default     = null
  description = "provisioner运行脚本"
}

variable "custom_image_scripts" {
  type        = list(string)
  default     = null
  description = "构建自定义镜像运行的脚本"
}

variable "gloden_image_scripts" {
  type        = list(string)
  default     = null
  description = "构建黄金镜像运行的脚本"
}

variable "custom_purpose" {
  type        = string
  default     = null
  description = "自定义构建目的"
}

/* -------- 插件特定变量 -------------- */
/////////////////////// vmware-iso///////////////////
variable "vmware_boot_wait" {
  type    = string
  default = null
}

variable "vmware_cdrom_adapter_type" {
  type        = string
  default     = "sata"
  description = "CDROM adapter type.  Needs to be SATA (or non-SCSI) for ARM64 builds."
}

variable "vmware_disk_adapter_type" {
  type        = string
  default     = "sata"
  description = "Disk adapter type.  Needs to be SATA (PVSCSI, or non-SCSI) for ARM64 builds."
}

variable "vmware_guest_os_type" {
  type        = string
  default     = null
  description = "OS type for virtualization optimization"
}

variable "vmware_tools_upload_flavor" {
  type        = string
  default     = null
  description = "要上传到虚拟机上的vmawre tools的风格. 支持darwin,linux,windows. 默认为空, 即vmware tools不会上传."
}


variable "vmware_tools_upload_path" {
  type        = string
  default     = null
  description = "vmware tools上传到虚拟机内的路径。仅在vmware_tools_upload_flavor不为空时才生效"
}

variable "vmware_version" {
  type        = number
  default     = 16
  description = "用于指明当前构建的vmware workstation版本. 如果版本不匹配, 会直接报错."
}

//
variable "vmware_vmx_data" {
  type = map(string)
  default = {
    //    "cpuid.coresPerSocket"    = "2"
    //    "ethernet0.pciSlotNumber" = "32"
    //    "svga.autodetect"         = true
    //    "usb_xhci.present"        = true
    // vwmware vmx必须设置该值。不然出现vmware dhcp无法识别mac地址的IP.
    //"ethernet0.connectionType" : "nat",
    // 设置虚拟机启动时连接网卡
    "ethernet0.startConnected" : "true",
    "ethernet0.addressType" : "generated",
    //"ethernet0.virtualDev" : "e1000"
    "ethernet0.present" : "TRUE"
    # 指定网卡编号为ens33
    //"ethernet0.pcislotnumber" : "33"
  }
  description = "vmx 配置.更多查阅:cttps://sanbarrow.com/vmx/vmx-network.html"
}
variable "vmware_vmx_remove_ethernet_interfaces" {
  type    = bool
  default = false
  // 注意：这个操作会导致在镜像创建后的网卡被删除, 从而导致创建的云服务器无法启动网卡分配IP。这个特性是供vagrant box使用。
  // vagrant box启动时会自动创建网卡, 但其他的如vmware workstation并不会。
  // 见https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/vmx
  description = "是否在构建玩镜像后删除所有网卡"
}
variable "vmware_enable_usb" {
  type    = bool
  default = true
}

variable "vmware_network_adapter_type" {
  type = string
  // default = "e1000e"
  default = "e1000"
}

variable "vmware_network" {
  type    = string
  default = "nat"
}

variable "vmware_disk_type_id" {
  type        = number
  default     = 0
  description = "设置虚拟磁盘类型。0表示保存到同一个文件"
}

variable "vmware_vnc_bind_address" {
  type    = string
  default = "127.0.0.1"
}

variable "vmware_vnc_disable_password" {
  type    = bool
  default = false
}

variable "vmware_vmdk_name" {
  type        = string
  default     = null
  description = "生成的磁盘镜像名.不设置则默认为disk"
}

variable "vmware_format" {
  type    = string
  default = null
  // 注意如果是ova必须安装ovftool工具,且ovftool程序在系统PATH路径上
  // format = "ova"
  description = "输出格式"
}

/////////////////////// vmware-vmx////////////////
variable "vmware_vmx_display_name" {
  type    = string
  default = null
  // https://github.com/hashicorp/packer/issues/7026
  description = "镜像实例名"
}

variable "vmware_vmx_source_path" {
  type        = string
  default     = null
  description = "源镜像路径"
}

variable "vmware_vmx_source_directory" {
  type        = string
  default     = null
  description = "源镜像路径目录"
}

variable "vmware_vmx_source_file_name" {
  type        = string
  default     = null
  description = "源镜像文件名"
}

variable "vmware_vmx_source_file_format" {
  type        = string
  default     = "vmx"
  description = "源镜像文件格式"
}

variable "vmware_vmx_linked" {
  type        = bool
  default     = false
  description = "是否采用链接克隆"
}

/////////////////////// alicloud-ecs////////////////
variable "alicloud_access_key" {
  type        = string
  default     = env("ALICLOUD_ACCESS_KEY")
  description = "access key to acess to the alicloud"

  // 设置validate后,即使执行其他的source build也会检测
  //   validation {
  //     condition     = length(var.alicloud_access_key) > 0
  //     error_message = <<EOF
  // The alicloud_access_key var is not set: make sure to at least set the ALICLOUD_ACCESS_KEY env var.
  // To fix this you could also set the alicloud_access_key variable from the arguments, for example:
  // $ packer build -var=alicloud_access_key=xxxx...
  // EOF
  //   }
}

variable "alicloud_secret_key" {
  type = string
  //这种写法也可以
  //default     = env("alicloud_secret_key")
  default     = env("ALICLOUD_SECRET_KEY")
  description = "secret key to acess to the alicloud"


  //   validation {
  //     condition     = length(var.alicloud_secret_key) > 0
  //     error_message = <<EOF
  // The alicloud_secret_key var is not set: make sure to at least set the ALICLOUD_SECRET_KEY env var.
  // To fix this you could also set the alicloud_access_key variable from the arguments, for example:
  // $ packer build -var=alicloud_secret_key=xxxx...
  // EOF
  //   }
}

variable "alicloud_instance_type" {
  type        = string
  default     = "ecs.t5-lc1m1.small"
  description = "阿里云构建镜像的实例规格"
}

variable "alicloud_internet_charge_type" {
  type        = string
  default     = "PayByTraffic"
  description = "阿里云流量付费方式"
}

variable "alicloud_io_optimized" {
  type        = bool
  default     = null
  description = "是否优化IO. 部分实例不支持"
}

variable "alicloud_region" {
  type        = string
  default     = "cn-shenzhen"
  description = "阿里云区域"
}

variable "alicloud_image_family" {
  type        = string
  default     = null
  description = "指定构建镜像的基础镜像所属族,如acs:centos_7_9_x64. 见https://help.aliyun.com/zh/ecs/user-guide/overview-45?spm=a2c4g.11186623.0.0.117e3a54BDq3jh"
}

variable "alicloud_source_image" {
  type    = string
  default = null
  //由于阿里云基础镜像每个月会更新,因此最好还是采用alicloud_image_family
  description = "指定构建镜像的基础镜像,如centos_7_9_x64_20G_alibase_20230919.vhd"
}

variable "alicloud_vm_associate_public_ip_address" {
  type        = bool
  default     = true
  description = "是否设置公网IP. 注意，如果不设置alicloud_ssh_private_ip，则设置外网IP,否则实例构建后无法通过ssh连接执行provisioner操作"
}

variable "alicloud_ssh_private_ip" {
  type        = bool
  default     = false
  description = "是否通过私网IP来连接ssh."
}

variable "alicloud_run_tags" {
  type        = map(string)
  default     = null
  description = "镜像标签"
}

variable "alicloud_description" {
  type        = string
  default     = null
  description = "镜像描述"
}

variable "alicloud_ssh_user" {
  type        = string
  default     = "root"
  description = "ssh用户"
}

variable "alicloud_image_encrypted" {
  type        = bool
  default     = null
  description = "是否对镜像加密"
}

/* ----------  alicloud-import -----------*/
variable "is_alicloud_import" {
  type        = bool
  default     = false
  description = "是否导入镜像到阿里云"
}

variable "alicloud_import_image_name" {
  type        = string
  default     = null
  description = "导入阿里云镜像的命名"
}

variable "alicloud_import_oss_bucket" {
  type        = string
  default     = "packer"
  description = "导入的存储桶名"
}

variable "alicloud_import_keep_input_artifact" {
  type        = bool
  default     = false
  description = "是否保存原镜像"
}

variable "alicloud_import_format" {
  type        = string
  default     = "RAW"
  description = "导入的镜像格式，仅支持RAW和VHD"
  validation {
    condition     = var.alicloud_import_format == "RAW" || var.alicloud_import_format == "VHD"
    error_message = <<EOF
Only support RAW and VHD.
EOF
  }
}
/////////////////////////hyperv-iso//////////////////////////
# Source block provider specific variables
# hyperv-iso
variable "hyperv_boot_wait" {
  type    = string
  default = null
}
variable "hyperv_enable_dynamic_memory" {
  type    = bool
  default = null
}
variable "hyperv_enable_secure_boot" {
  type    = bool
  default = null
}
variable "hyperv_generation" {
  type        = number
  default     = 2
  description = "Hyper-v generation version"
}
variable "hyperv_guest_additions_mode" {
  type    = string
  default = "disable"
}
variable "hyperv_switch_name" {
  type    = string
  default = "Default Switch"
  // 测试时不设置或者为null, 默认会创建一个`packer-vm`的内部网络虚拟交换机
  // 会因为无法分配IP给虚拟机则创建失败
  description = "创建的虚拟机连接的虚拟交换机"
}

//////////////////////virtualbox-iso////////////////////////////////
# virtualbox-iso
variable "virtualbox_boot_wait" {
  type    = string
  default = null
}
variable "virtualbox_gfx_controller" {
  type    = string
  default = null
}
variable "virtualbox_gfx_vram_size" {
  type    = number
  default = null
}
variable "virtualbox_guest_additions_interface" {
  type    = string
  default = "sata"
}
variable "virtualbox_guest_additions_mode" {
  type    = string
  default = null
}
variable "virtualbox_guest_additions_path" {
  type    = string
  default = "VBoxGuestAdditions_{{ .Version }}.iso"
}
variable "virtualbox_guest_os_type" {
  type        = string
  default     = null
  description = "OS type for virtualization optimization"
}
variable "virtualbox_hard_drive_interface" {
  type    = string
  default = "sata"
}
variable "virtualbox_iso_interface" {
  type    = string
  default = "sata"
}
variable "virtualbox_manage" {
  type = list(list(string))
  default = [
    [
      "modifyvm",
      "{{.Name}}",
      "--audio",
      "none",
      "--nat-localhostreachable1",
      "on",
    ]
  ]
}
variable "virtualbox_version_file" {
  type    = string
  default = ".vbox_version"
}


////////////////// parallels-iso ////////////////////
# parallels-iso
variable "parallels_boot_wait" {
  type    = string
  default = null
}
variable "parallels_guest_os_type" {
  type        = string
  default     = null
  description = "OS type for virtualization optimization"
}
variable "parallels_tools_flavor" {
  type    = string
  default = null
}
variable "parallels_tools_mode" {
  type    = string
  default = null
}
variable "parallels_prlctl" {
  type    = list(list(string))
  default = null
}
variable "parallels_prlctl_version_file" {
  type    = string
  default = ".prlctl_version"
}

////////////////// qemu ////////////////////
# qemu
variable "qemu_accelerator" {
  type    = string
  default = null
}
variable "qemu_binary" {
  type    = string
  default = null
}
variable "qemu_boot_wait" {
  type    = string
  default = null
}
variable "qemu_display" {
  type    = string
  default = "none"
}
variable "qemu_machine_type" {
  type    = string
  default = null
}
variable "qemu_args" {
  type    = list(list(string))
  default = null
}

variable "qemu_format" {
  type        = string
  default     = null
  description = "虚拟机镜像输出格式, 支持raw或者qcow2, 默认为qcow2."
}

variable "qemu_disk_image" {
  type        = bool
  default     = null
  description = "是否从镜像(而非iso)来构建虚拟机镜像."
}