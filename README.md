# 架构
* `builds`: 默认镜像输出路径,通过`-var output_directory`来设置
* `hack`: 一些脚本
* `make-rules`: makefile 构建规则
* `os_pkrvars`: 各个操作系统特殊变量赋值
* `packer_templates`: packer模板定义

# 首次运行
0.  由于插件都在github上,配置代理
    ```
        export HTTPS_PROXY=xxx
        export HTTP_PROXY=xxx
    ```
1. 执行`packer init ./packer_templates`下载插件

# 运行
## 构建vmware-iso的Ubuntu 16.04镜像
`PACKER_CACHE_DIR=/f/build_cache packer build -on-error=ask -only=*.vmware-iso.vm -var-file ./os_pkrvars/ubuntu/ubuntu-16.04-x86_64.pkrvars.hcl -var output_directory=/f/build ./packer_templates/`
* `PACKER_CACHE_DIR`: 设置packer缓存目录,用于缓存下载的镜像仓库等。 默认是`./packer_cache`.
* `-var output_directory=/f/build`: 指定镜像输出目录。

## 构建vmware-iso的window 镜像
1. 安装[oscdimg工具](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install), 原因[详情](https://github.com/hashicorp/packer-plugin-vsphere/issues/181)
2. `PACKER_CACHE_DIR=/f/build_cache packer build -on-error=ask -only=*.vmware-iso.vm -var-file ./os_pkrvars/windows/windows-10-x86_64.pkrvars.hcl -var output_directory=/f/build ./packer_templates/`

## 构建vmware-vmx的Ubuntu 16.04镜像
`PACKER_CACHE_DIR=/f/build_cache packer build  -on-error=ask -only=*.vmware-vmx.vm -var custom_purpose=goss -var-file ./os_pkrvars/ubuntu/ubuntu-16.04-x86_64.pkrvars.hcl -var output_directory=/f/build   ./packer_templates/`
*  `custom_purpose=goss`: 必传，表明当基于黄金镜像的构建目的。根据不同的目的执行不同的脚本
    * goss: goss测试用
    * none: 只打印环境变量，测试用
    * docker: 安装docker
    * kubernetes: 安装kubernetes预部署环境. 包括依赖镜像、kubelet等工具
* `-var-file ./os_pkrvars/ubuntu/ubuntu-16.04-x86_64.pkrvars.hcl`: 如果不通过`vmware_vmx_source_path`指定黄金镜像路径时，默认是源为`${local.output_directory}/${var.os_name}/${var.os_type}/${var.os_arch}.vmx`

## 构建alicloud-ecs镜像
1.  配置账号密码
    ```
        export ALICLOUD_ACCESS_KEY=xxx
        export ALICLOUD_SECRET_KEY=xxx
    ```
2. `PACKER_CACHE_DIR=/f/build_cache packer build  -on-error=ask -only=*.alicloud-ecs.vm -var-file ./os_pkrvars/ubuntu/ubuntu-16.04-x86_64.pkrvars.hcl -var output_directory=/f/build ./packer_templates/`
### 注意
* 如果需要将格式转换成ova格式, 需要安装ova必须安装ovftool工具,且将ovftool程序路径添加环境变量PATH中

# Makefile运行
## 模板
### 检测
* `make validate.template.qemu.ubuntu-16.04`构建模板
* `make validate.template.qemu.ubuntu-16.04 VARS="vmware-format=ova"`构建模板，并传递packer参数"-var vmware-format=ova"
### 解析
* `make inspect.template.qemu.ubuntu-16.04`构建模板
* `make inspect.template.qemu.ubuntu-16.04 VARS="vmware-format=ova"`构建模板，并传递packer参数"-var vmware-format=ova"

### 构建
* `make build.template.qemu.ubuntu-16.04`构建模板
* `make build.template.qemu.ubuntu-16.04 VARS="vmware-format=ova"`构建模板，并传递packer参数"-var vmware-format=ova"
## 自定义镜像
### 检测
* `make validate.template.qemu.ubuntu-16.04`构建模板
* `make validate.template.qemu.ubuntu-16.04 VARS="vmware-format=ova"`构建模板，并传递packer参数"-var vmware-format=ova"
### 解析
* `make inspect.template.qemu.ubuntu-16.04`构建模板
* `make inspect.template.qemu.ubuntu-16.04 VARS="vmware-format=ova"`构建模板，并传递packer参数"-var vmware-format=ova"
### 构建
* `make build.custom.kubernetes.qemu.ubuntu-16.04`
* `make build.cutome.kubernetes.qemu.ubuntu-16.04 VARS="vmware-format=ova"`构建模板，并传递packer参数"-var vmware-format=ova"
