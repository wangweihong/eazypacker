
/////////////////////// Provisioner脚本 ///////////////////////
locals {

  // 自定义镜像脚本
  custom_image_scripts = var.custom_image_scripts == null ? (
    var.custom_purpose == null ? [
      "${path.root}/scripts/_common/debug.sh"
      ] : [
      //TODO: otherpurpose
    ]
  ) : var.custom_image_scripts

  // 黄金镜像构建脚本
  gloden_image_scripts = var.gloden_image_scripts == null ? (
    var.is_windows ? [
      "${path.root}/scripts/windows/provision.ps1",
      "${path.root}/scripts/windows/configure-power.ps1",
      "${path.root}/scripts/windows/disable-windows-uac.ps1",
      "${path.root}/scripts/windows/disable-system-restore.ps1",
      "${path.root}/scripts/windows/disable-screensaver.ps1",
      "${path.root}/scripts/windows/ui-tweaks.ps1",
      "${path.root}/scripts/windows/disable-windows-updates.ps1",
      "${path.root}/scripts/windows/disable-windows-defender.ps1",
      "${path.root}/scripts/windows/remove-one-drive-and-teams.ps1",
      "${path.root}/scripts/windows/remove-apps.ps1",
      "${path.root}/scripts/windows/enable-remote-desktop.ps1",
      "${path.root}/scripts/windows/enable-file-sharing.ps1",
      "${path.root}/scripts/windows/eject-media.ps1"
      ] : (
      var.os_name == "opensuse" ||
      var.os_name == "sles" ? [
        "${path.root}/scripts/suse/repositories_suse.sh",
        "${path.root}/scripts/suse/update_suse.sh",
        "${path.root}/scripts/_common/motd.sh",
        "${path.root}/scripts/_common/sshd.sh",
        "${path.root}/scripts/_common/vagrant.sh",
        "${path.root}/scripts/suse/unsupported-modules_suse.sh",
        "${path.root}/scripts/_common/virtualbox.sh",
        "${path.root}/scripts/_common/vmware_suse.sh",
        "${path.root}/scripts/_common/parallels.sh",
        "${path.root}/scripts/suse/vagrant_group_suse.sh",
        "${path.root}/scripts/suse/sudoers_suse.sh",
        "${path.root}/scripts/suse/zypper-locks_suse.sh",
        "${path.root}/scripts/suse/remove-dvd-source_suse.sh",
        "${path.root}/scripts/suse/cleanup_suse.sh",
        "${path.root}/scripts/_common/minimize.sh"
        ] : (
        var.os_name == "ubuntu" ||
        var.os_name == "debian" ? [
          // 更新/禁用系统软件
          "${path.root}/scripts/${var.os_name}/update_${var.os_name}.sh",
          // 配置用户登录欢迎信息
          "${path.root}/scripts/_common/motd.sh",
          // 配置sshd安全性
          "${path.root}/scripts/_common/sshd.sh",
          // 配置网络
          "${path.root}/scripts/${var.os_name}/networking_${var.os_name}.sh",
          // 配置sudo用户权限
          "${path.root}/scripts/${var.os_name}/sudoers_${var.os_name}.sh",
          "${path.root}/scripts/${var.os_name}/systemd_${var.os_name}.sh",
          "${path.root}/scripts/_common/vmware_debian_ubuntu.sh",
          "${path.root}/scripts/${var.os_name}/cleanup_${var.os_name}.sh",
          "${path.root}/scripts/_common/minimize.sh"
          ] : (
          "${var.os_name}-${substr(var.os_version, 0, 1)}" == "centos-7" ||
          "${var.os_name}-${substr(var.os_version, 0, 1)}" == "rhel-7" ? [
            "${path.root}/scripts/rhel/update_yum.sh",
            "${path.root}/scripts/_common/motd.sh",
            "${path.root}/scripts/_common/sshd.sh",
            "${path.root}/scripts/rhel/networking_rhel7.sh",
            "${path.root}/scripts/_common/virtualbox.sh",
            "${path.root}/scripts/_common/vmware_rhel.sh",
            "${path.root}/scripts/rhel/cleanup_yum.sh",
            "${path.root}/scripts/_common/minimize.sh"
            ] : [
            "${path.root}/scripts/rhel/update_dnf.sh",
            "${path.root}/scripts/_common/motd.sh",
            "${path.root}/scripts/_common/sshd.sh",
            "${path.root}/scripts/_common/virtualbox.sh",
            "${path.root}/scripts/_common/vmware_rhel.sh",
            "${path.root}/scripts/rhel/cleanup_dnf.sh",
            "${path.root}/scripts/_common/minimize.sh"
          ]
        )
      )
    )
  ) : var.gloden_image_scripts
}
