
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
    "USE_ALICLOUD=${var.use_alicloud}",
  ]

  kubernetes_env = [
    "KUBE_WORKER=${var.is_kubernetes_worker}",
    "HELM_VERSION=${var.helm_version}",
    "KUBE_VERSION=${var.kubernetes_version}",
    # "KUBE_CRI=${var.kubernetes_cri}",
    # "HTTP_PROXY=${var.http_proxy}",
    # "HTTPS_PROXY=${var.https_proxy}",
    # "NO_PROXY=localhost,127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.svc,.cluster.local,.ewhisper.cn,<nodeCIDR>,<APIServerInternalURL>,<serviceNetworkCIDRs>,<etcdDiscoveryDomain>,<clusterNetworkCIDRs>,<platformSpecific>,<REST_OF_CUSTOM_EXCEPTIONS>",
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

  custom_env = (var.custom_purpose == "kubernetes" ? local.kubernetes_env :
    var.custom_purpose == "golang" ? local.golang_env :
    var.custom_purpose == "gitlab-runner" ? local.gitlab_runner_env :
    var.custom_purpose == "database" ? local.database_env :
    var.custom_purpose == "iac" ? local.iac_env :
    var.custom_purpose == "harbor" ? local.harbor_env : []
  )

  /*--------------  scripts -------------------*/
  common_scripts = [
    #"${path.root}/scripts/_common/none.sh",
  ]

  expect_scripts     = ["${path.root}/scripts/_common/expect.sh"]
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


  pre_docker_scripts = var.os_name == "ubuntu" ? ([
    "${path.root}/scripts/ubuntu/install_apt_proxy.sh",
    "${path.root}/scripts/custom/docker/install_docker.sh",
    "${path.root}/scripts/custom/docker/config_docker_proxy.sh",
  ]) : local.no_support_scripts

  post_docker_scripts = var.os_name == "ubuntu" ? ([
    "${path.root}/scripts/custom/docker/config_docker_proxy.sh",
    "${path.root}/scripts/ubuntu/cleanup_apt_proxy.sh"
  ]) : local.no_support_scripts

  docker_scripts = concat(
    local.pre_docker_scripts,
    ["${path.root}/scripts/ubuntu/cleanup_apt_proxy.sh"],
    local.post_docker_scripts,
  )

  elk_common_scripts = [
    "${path.root}/scripts/_common/expect.sh",
    "${path.root}/scripts/custom/elk/es.sh",
    "${path.root}/scripts/custom/elk/es_password.sh",
    "${path.root}/scripts/custom/elk/es_tls.sh",
    "${path.root}/scripts/custom/elk/es_plugin.sh",
    "${path.root}/scripts/custom/elk/head.sh",
    "${path.root}/scripts/custom/elk/kibana.sh",
  ]

  elk_need_docker_scripts = concat(
    local.pre_docker_scripts,
    local.elk_common_scripts,
    local.post_docker_scripts
  )

  elk_scripts = var.os_name == "ubuntu" ? (
    var.os_version == "16.04" ? local.no_support_scripts : (
      var.has_docker ? local.elk_common_scripts : local.elk_need_docker_scripts
    )
  ) : local.no_support_scripts

  harbor_scripts = concat(
    local.pre_docker_scripts,
    ["${path.root}/scripts/custom/harbor/install.sh"],
    local.post_docker_scripts,
  )

  jenkins_scripts = var.has_docker ? local.jenkins_common_scripts : local.jenkins_need_docker_scripts

  jenkins_need_docker_scripts = concat(
    local.pre_docker_scripts,
    local.jenkins_common_scripts,
    local.post_docker_scripts
  )


  jenkins_common_scripts = concat(
    ["${path.root}/scripts/custom/devops/jenkins/install.sh"],
  )

  artifactory_scripts = var.has_docker ? local.artifactory_common_scripts : local.artifactory_need_docker_scripts

  artifactory_common_scripts = concat(
    local.expect_scripts,
    ["${path.root}/scripts/custom/artifactory/install.sh"]
  )

  artifactory_need_docker_scripts = concat(
    local.pre_docker_scripts,
    local.artifactory_common_scripts,
    local.post_docker_scripts
  )

  k3s_scripts = ["${path.root}/scripts/custom/k3s/install.sh"]

  // kubernetes_containerd_scripts = [
  //   "${path.root}/scripts/_common/yq.sh",
  //   "${path.root}/scripts/custom/kubernetes/environment.sh",
  //   "${path.root}/scripts/custom/kubernetes/install_kube_tools.sh",
  //   "${path.root}/scripts/custom/kubernetes/tools/containerd/install_containerd.sh",
  //   "${path.root}/scripts/custom/kubernetes/tools/containerd/install_cri_tools.sh",
  //   "${path.root}/scripts/custom/kubernetes/tools/containerd/config_proxy.sh",
  //   "${path.root}/scripts/custom/kubernetes/tools/helm/install_helm.sh",
  //   "${path.root}/scripts/custom/kubernetes/tools/kustomize/install.sh",
  //   "${path.root}/scripts/custom/kubernetes/prepare_install.sh",
  //   "${path.root}/scripts/custom/kubernetes/gen_install_script.sh",
  //   "${path.root}/scripts/custom/kubernetes/tools/containerd/cleanup_proxy.sh",
  // ]

  // kubernetes_docker_scripts = var.os_name == "ubuntu" ? (
  //   var.os_version == "16.04" ? [
  //     "${path.root}/scripts/_common/yq.sh",
  //     "${path.root}/scripts/ubuntu/install_apt_proxy.sh",
  //     "${path.root}/scripts/custom/docker/install_docker.sh",
  //     "${path.root}/scripts/custom/docker/config_docker_proxy.sh",
  //     "${path.root}/scripts/custom/kubernetes/install_kube_tools.sh",
  //     "${path.root}/scripts/custom/kubernetes/tools/helm/install_helm.sh",
  //     "${path.root}/scripts/custom/kubernetes/tools/kustomize/install.sh",
  //     "${path.root}/scripts/custom/kubernetes/prepare_install.sh",
  //     "${path.root}/scripts/custom/kubernetes/gen_install_script.sh",
  //     "${path.root}/scripts/custom/docker/cleanup_docker_proxy.sh",
  //     "${path.root}/scripts/ubuntu/cleanup_apt_proxy.sh",
  //   ] : local.no_support_scripts
  // ) : local.no_support_scripts

  // kubernetes_scripts = var.kubernetes_cri == "containerd" ? local.kubernetes_containerd_scripts : local.kubernetes_docker_scripts

  inline_custom_image_scripts = var.inline_custom_image_scripts != null ? var.inline_custom_image_scripts : (
    var.custom_purpose == "kubernetes" ? [
      "env",
      "chmod +x -R /tmp/kubernetes",
      "chmod +x -R /tmp/docker",
      "chmod +x -R /tmp/ubuntu",
      "chmod +x /tmp/yq.sh",
      "/tmp/yq.sh",
      "/tmp/kubernetes/run.sh"
    ] :
    ["env"]
  )

  custom_image_scripts = var.custom_image_scripts == null ? (
    var.custom_purpose == null || var.custom_purpose == "none" ? local.none_scripts :
    # var.custom_purpose == "kubernetes" ? local.kubernetes_scripts :
    # 通过上传脚本到构建器, 通过inline shell来执行kubernetes安装, 这里不做任何操作。
    var.custom_purpose == "kubernetes" ? local.none_scripts :
    var.custom_purpose == "gitlab-runner" ? local.gitlab_runner_scripts :
    var.custom_purpose == "goss" ? local.goss_scripts :
    var.custom_purpose == "k3s" ? local.k3s_scripts :
    var.custom_purpose == "golang" ? local.golang_scripts :
    var.custom_purpose == "database" ? local.database_scripts :
    var.custom_purpose == "iac" ? local.iac_scripts :
    var.custom_purpose == "harbor" ? local.harbor_scripts :
    var.custom_purpose == "docker" ? local.docker_scripts :
    var.custom_purpose == "elk" ? local.elk_scripts :
    var.custom_purpose == "argocd" ? local.argocd_scripts :
    var.custom_purpose == "artifactory" ? local.artifactory_scripts :
    var.custom_purpose == "jenkins" ? local.jenkins_scripts : local.no_support_scripts
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


  artifactory_upload_files = [
    "${path.root}/scripts/custom/artifactory/artifactory-injector-1.1.jar"
  ]

  // 自定义镜像执行脚本前上传文件到构建实例(如果置为null, 则不会上传)
  custom_image_pre_upload_files = var.custom_purpose != "artifactory" ? (
    # 上传kubernetes部署脚本到构建环境
    var.custom_purpose == "kubernetes" ? [
      "${path.root}/scripts/custom/kubernetes",
      "${path.root}/scripts/custom/docker",
      "${path.root}/scripts/_common/yq.sh",
      "${path.root}/scripts/ubuntu",
      "${path.root}/scripts/ubuntu/cleanup_apt_proxy.sh",
    ] : null
  ) : local.artifactory_upload_files

  // 自定义镜像执行脚本后从构建实例下载文件(如果置为null, 则不会下载)
  custom_image_post_download_source      = var.custom_purpose == "artifactory" ? ["/tmp/jfrog.license"] : null
  custom_image_post_download_destination = local.download_file_path
  # 下载文件路径(下载到指定目录)
  download_file_path = "${path.root}/../builds/download/"
}

