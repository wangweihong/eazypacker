
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
    "IS_WORKER=${var.is_kubernetes_worker}",
    "HELM_VERSION=${var.helm_version}",
  ]
  golang_env = [
    "GO_VERSION=${var.go_version}",
  ]
  gitlab_runner_env = [
    "USE_ALICLOUD=${var.use_alicloud}",
  ]
  database_env = [
    "DATABASE_TYPE=${var.database_type}",
    "DATABASE_VERSION=${var.database_version}",
  ]
  harbor_env = [
    "HARBOR_DOMAIN=${var.harbor_domain}",
    "HARBOR_VERSION=${var.harbor_version}",
  ]
  iac_env = [
    "PULUMI_VERSION=${var.pulumi_version}",
    "TERRAFORM_VERSION=${var.terraform_version}",
  ]

  custom_env = var.custom_purpose == "kubernetes" ? local.kubernetes_env : (
    var.custom_purpose == "golang" ? local.golang_env : (
      var.custom_purpose == "gitlab-runner" ? local.gitlab_runner_env : (
        var.custom_purpose == "database" ? local.database_env : (
          var.custom_purpose == "iac" ? local.iac_env : (
            var.custom_purpose == "harbor" ? local.harbor_env : []
          )
        )
      )
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
  argocd_scripts        = ["${path.root}/scripts/custom/cicd/argocd/install.sh"]
  database_scripts      = ["${path.root}/scripts/custom/database/${var.database_type}/install_${var.database_version}.sh"]
  iac_scripts = [
    "${path.root}/scripts/custom/iac/pulumi/install.sh",
    "${path.root}/scripts/custom/iac/terraform/install.sh",
  ]

  docker_scripts = concat(
    local.pre_docker_scripts,
    ["${path.root}/scripts/ubuntu/cleanup_apt_proxy.sh"]
  )

  elk_common_scripts = [
    "${path.root}/scripts/_common/expect.sh",
    "${path.root}/scripts/custom/elk/install.sh",  
 #   "${path.root}/scripts/custom/elk/kibana.sh",
    "${path.root}/scripts/custom/elk/password.sh",

  ]

  elk_need_docker_scripts = concat(
    local.pre_docker_scripts,
    local.elk_common_scripts,
    local.post_docker_scripts
  )

  elk_scripts = var.has_docker ? local.elk_common_scripts : local.elk_need_docker_scripts


  pre_docker_scripts = var.os_name == "ubuntu" ? ([
    "${path.root}/scripts/ubuntu/install_apt_proxy.sh",
    "${path.root}/scripts/custom/docker/install_docker.sh",
    "${path.root}/scripts/custom/docker/config_docker_proxy.sh",
  ]) : local.no_support_scripts
  post_docker_scripts = var.os_name == "ubuntu" ? ([
    "${path.root}/scripts/custom/docker/config_docker_proxy.sh",
    "${path.root}/scripts/ubuntu/cleanup_apt_proxy.sh"
  ]) : local.no_support_scripts

  harbor_scripts = concat(
    local.pre_docker_scripts,
    ["${path.root}/scripts/custom/harbor/install.sh"],
    local.post_docker_scripts,
  )

  k3s_scripts = ["${path.root}/scripts/custom/k3s/install.sh"]
  kubernetes_scripts = var.os_name == "ubuntu" ? (
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
      var.custom_purpose == "kubernetes" ? local.kubernetes_scripts : (
        var.custom_purpose == "gitlab-runner" ? local.gitlab_runner_scripts : (
          var.custom_purpose == "goss" ? local.goss_scripts : (
            var.custom_purpose == "k3s" ? local.k3s_scripts : (
              var.custom_purpose == "golang" ? local.golang_scripts : (
                var.custom_purpose == "database" ? local.database_scripts : (
                  var.custom_purpose == "iac" ? local.iac_scripts : (
                    var.custom_purpose == "harbor" ? local.harbor_scripts : (
                      var.custom_purpose == "docker" ? local.docker_scripts : (
                        var.custom_purpose == "elk" ? local.elk_scripts : (
                          var.custom_purpose == "argocd" ? local.argocd_scripts : local.no_support_scripts
                        )
                      )
                    )
                  )
                )
              )
            )
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
