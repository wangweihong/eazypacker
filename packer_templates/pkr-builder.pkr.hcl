packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/vmware"
    }
    windows-update = {
      version = ">= 0.14.1"
      source  = "github.com/rgl/windows-update"
    }
    hyperv = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/hyperv"
    }
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
    parallels = {
      version = ">= 1.0.2"
      source  = "github.com/parallels/parallels"
    }
    qemu = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/qemu"
    }
    alicloud = {
      source  = "github.com/hashicorp/alicloud"
      version = ">= v1.1.1"
    }
  }

}


locals {
  build_version_path  = var.build_version_path == null ? "${path.root}/../.build_version" : var.build_version_path
  vagrant_output_path = var.output_directory == null ? "${path.root}/../builds" : var.output_directory
  //这里的目的是用于控制except
  golden_image_source_names = [for source in var.golden_image_sources_enabled : trimprefix(source, "source.")]
  custom_image_source_names = [for source in var.golden_image_sources_enabled : trimprefix(source, "source.")]

}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  // TODO: 考虑将其他基于黄金镜像的特定用户镜像, 基于公有云的镜像等都创建一个构建块。
  // 再利用[only/except](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/onlyexcept)来单独构建
  // 强调当前构建块目的是构建黄金镜像
  name = "golden_image"

  sources = var.golden_image_sources_enabled

  # Linux Shell scipts
  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant",
      "http_proxy=${var.http_proxy}",
      "https_proxy=${var.https_proxy}",
      "no_proxy=${var.no_proxy}",
    ]

    //运行shell脚本时使用的命令
    //如果 var.os_name 是 "freebsd"，则使用 su 命令以 root 用户身份执行脚本。
    //如果 var.os_name 是 "solaris"，则使用 sudo 命令以 root 用户身份执行脚本。
    //如果 var.os_name 不是 "freebsd" 也不是 "solaris"，则使用 sudo 命令以 root 用户身份执行脚本。
    execute_command = var.os_name == "freebsd" ? "echo 'vagrant' | {{.Vars}} su -m root -c 'sh -eux {{.Path}}'" : (
      var.os_name == "solaris" ? "echo 'vagrant'|sudo -S bash {{.Path}}" : "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    )
    //在执行脚本后，预期会断开与远程主机的连接
    expect_disconnect = true
    //要执行的脚本列表
    scripts = local.gloden_image_scripts
    //避免在windows执行
    except = var.is_windows ? local.golden_image_source_names : null
  }

  # Windows Updates and scripts
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    except          = var.is_windows ? null : local.golden_image_source_names
  }
  provisioner "windows-restart" {
    except = var.is_windows ? null : local.golden_image_source_names
  }
  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    scripts           = local.scripts
    except            = var.is_windows ? null : local.golden_image_source_names
  }
  provisioner "windows-restart" {
    except = var.is_windows ? null : local.golden_image_source_names
  }
  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    scripts = [
      "${path.root}/scripts/windows/cleanup.ps1",
      "${path.root}/scripts/windows/optimize.ps1"
    ]
    except = var.is_windows ? null : local.golden_image_source_names
  }
  provisioner "windows-restart" {
    except = var.is_windows ? null : local.golden_image_source_names
  }

  // genenrate manifests to record image build info
  post-processor "manifest" {
    custom_data = {
      "release_version" : var.release_version,
      "build_timestamp" : formatdate("YYYYMMDDHHMM", timestamp()),
      "distro_arch" : var.os_arch,
      "distro_name" : var.os_name,
      "distro_version" : var.os_version,
    }
    output     = "${local.output_directory}/${source.type}-manifest.json"
    strip_path = true
  }

  # Convert machines to vagrant boxes
  post-processor "vagrant" {
    compression_level    = 9
    keep_input_artifact  = var.keep_input_artifact
    output               = "${local.vagrant_output_path}/${var.os_name}-${var.os_version}-${var.os_arch}.{{ .Provider }}.box"
    vagrantfile_template = var.is_windows ? "${path.root}/vagrantfile-windows.template" : null
    // 没有设置的话则直接忽略掉该post-processor
    except = var.is_vagranted ? null : local.golden_image_source_names
  }

}

build {
  name = "custom_image"

  sources = var.custom_image_sources_enabled

  # Linux Shell scipts
  provisioner "shell" {
    environment_vars = concat(local.common_env , local.custom_env)

    //运行shell脚本时使用的命令
    //如果 var.os_name 是 "freebsd"，则使用 su 命令以 root 用户身份执行脚本。
    //如果 var.os_name 是 "solaris"，则使用 sudo 命令以 root 用户身份执行脚本。
    //如果 var.os_name 不是 "freebsd" 也不是 "solaris"，则使用 sudo 命令以 root 用户身份执行脚本。
    execute_command = source.type == "alicloud-ecs" ? "{{ .Path}}" : (
      var.os_name == "freebsd" ? "echo 'vagrant' | {{.Vars}} su -m root -c 'sh -eux {{.Path}}'" : (
      var.os_name == "solaris" ? "echo 'vagrant'|sudo -S bash {{.Path}}" : "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'")
    )
    //在执行脚本后，预期会断开与远程主机的连接
    expect_disconnect = true
    //要执行的脚本列表
    //通过concat连接通用脚本
    scripts = concat(local.common_scripts , local.custom_image_scripts)
    //避免在windows执行
    except = var.is_windows ? local.custom_image_source_names : null
  }


  // genenrate manifests to record image build info
  post-processor "manifest" {
    custom_data = {
      "release_version" : var.release_version,
      "build_timestamp" : formatdate("YYYYMMDDHHMM", timestamp()),
      "distro_arch" : var.os_arch,
      "distro_name" : var.os_name,
      "distro_version" : var.os_version,
    }
    output     = var.custom_purpose == null ? "${local.output_directory}/${source.type}-manifest.json" : "${local.output_directory}/${var.custom_purpose}-manifest.json"
    strip_path = true
  }
}