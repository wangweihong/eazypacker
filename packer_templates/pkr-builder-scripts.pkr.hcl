
/////////////////////// Provisioner脚本 ///////////////////////
locals {
  /*--------------  env -------------------*/
  common_env = [
    "HOME_DIR=/home/vagrant",
    "http_proxy=${var.http_proxy}",
    "https_proxy=${var.https_proxy}",
    "no_proxy=${var.no_proxy}",
    "OS_VERSION=${var.os_version}",
    "OS_ARCH=${var.os_arch}",
    "OS_NAME=${var.os_name}",
  ]
  kubernetes_env = [
    "USE_ALICLOUD=${var.use_alicloud}",
  ]
  golang_env = [
    "GO_VERSION=${var.go_version}",
  ]
  gitlab_runner_env = [
    "USE_ALICLOUD=${var.use_alicloud}",
  ]

  custom_env = var.custom_purpose == "kubernetes" ? local.kubernetes_env : (
    var.custom_purpose == "golang" ? local.golang_env : (
      var.custom_purpose == "gitlab-runner" ? local.gitlab_runner_env : []
    )
  )
  /*--------------  scripts -------------------*/
  common_scripts = [
    "${path.root}/scripts/_common/none.sh",
  ]
  no_support_scripts = ["${path.root}/scripts/_common/no_support.sh"]
  goss_scripts       = ["${path.root}/scripts/_common/goss.sh"]
  none_scripts = [
    "${path.root}/scripts/_common/none.sh",
  ]
  golang_scripts        = ["${path.root}/scripts/custom/golang/install.sh"]
  gitlab_runner_scripts = ["${path.root}/scripts/custom/gitlab/runner/install.sh"]
  github_runner_scripts = local.no_support_scripts
  kuberntes_scripts = var.os_name == "ubuntu" ? (
    var.os_version == "16.04" ? [
      "${path.root}/scripts/ubuntu/install_apt_proxy.sh",
      "${path.root}/scripts/custom/docker/install_docker.sh",
      "${path.root}/scripts/custom/docker/config_docker_proxy.sh",
      "${path.root}/scripts/custom/kubernetes/install_kube_tools.sh",
      // install_helm take too long to install. 
      //"${path.root}/scripts/custom/helm/install_helm.sh",
      "${path.root}/scripts/_common/yq.sh",
      "${path.root}/scripts/custom/kubernetes/prepare_install.sh",
      "${path.root}/scripts/custom/kubernetes/gen_install_script.sh",
      "${path.root}/scripts/custom/docker/cleanup_docker_proxy.sh",
      "${path.root}/scripts/ubuntu/cleanup_apt_proxy.sh",

    ] : local.no_support_scripts
  ) : local.no_support_scripts


  custom_image_scripts = var.custom_image_scripts == null ? (
    var.custom_purpose == null || var.custom_purpose == "none" ? local.none_scripts : (
      var.custom_purpose == "kubernetes" ? local.kuberntes_scripts : (
        var.custom_purpose == "gitlab-runner" ? local.gitlab_runner_scripts : (
          var.custom_purpose == "goss" ? local.goss_scripts : (
            var.custom_purpose == "golang" ? local.golang_scripts : local.no_support_scripts
          )
        )
      )
    )
  ) : var.custom_image_scripts
  // 自定义镜像脚本


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
