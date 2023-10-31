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
  }

}


locals {
  build_version_path  = var.build_version_path == null ? "${path.root}/../.build_version" : var.build_version_path
  vagrant_output_path = var.output_directory == null ? "${path.root}/../builds" : var.output_directory

  sources_enabled = var.is_golden_image_build == true ? var.sources_enabled : var.images_enabled
  //根据不同目的来搭配脚本
  scripts = var.scripts == null ? (
    var.is_golden_image_build == true ? local.gloden_image_scripts : local.custom_image_scripts
  ) : var.scipts

  source_names = [for source in var.sources_enabled : trimprefix(source, "source.")]

}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  // TODO: 考虑将其他基于黄金镜像的特定用户镜像, 基于公有云的镜像等都创建一个构建块。
  // 再利用[only/except](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/onlyexcept)来单独构建
  // 强调当前构建块目的是构建黄金镜像
  name = "golden_image"

  sources = local.sources_enabled

  # Linux Shell scipts
  provisioner "shell" {
    environment_vars = var.os_name == "freebsd" ? [
      "HOME_DIR=/home/vagrant",
      "http_proxy=${var.http_proxy}",
      "https_proxy=${var.https_proxy}",
      "no_proxy=${var.no_proxy}",
      "pkg_branch=quarterly",
      ] : (
      var.os_name == "solaris" ? [] : [
        "HOME_DIR=/home/vagrant",
        "http_proxy=${var.http_proxy}",
        "https_proxy=${var.https_proxy}",
        "no_proxy=${var.no_proxy}",
        "replace_app_srouce=${var.replace_app_source}"
      ]
    )
    execute_command = var.os_name == "freebsd" ? "echo 'vagrant' | {{.Vars}} su -m root -c 'sh -eux {{.Path}}'" : (
      var.os_name == "solaris" ? "echo 'vagrant'|sudo -S bash {{.Path}}" : "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    )
    expect_disconnect = true
    scripts           = local.scripts
    except            = var.is_windows ? local.source_names : null
  }

  // provisioner "file" {
  //   source      = local.build_version_path
  //   destination = "$HOME_DIR/.build_version"
  // }

  # Windows Updates and scripts
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    except          = var.is_windows ? null : local.source_names
  }
  provisioner "windows-restart" {
    except = var.is_windows ? null : local.source_names
  }
  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    scripts           = local.scripts
    except            = var.is_windows ? null : local.source_names
  }
  provisioner "windows-restart" {
    except = var.is_windows ? null : local.source_names
  }
  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    scripts = [
      "${path.root}/scripts/windows/cleanup.ps1",
      "${path.root}/scripts/windows/optimize.ps1"
    ]
    except = var.is_windows ? null : local.source_names
  }
  provisioner "windows-restart" {
    except = var.is_windows ? null : local.source_names
  }

  # Convert machines to vagrant boxes
  // post-processor "vagrant" {
  //   compression_level    = 9
  //   output               = "${local.vagrant_output_path}/${var.os_name}-${var.os_version}-${var.os_arch}.{{ .Provider }}.box"
  //   vagrantfile_template = var.is_windows ? "${path.root}/vagrantfile-windows.template" : null
  // }
}
