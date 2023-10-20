# 架构
* `builds`: 默认镜像输出路径,通过`-var output_directory`来设置
* `hack`: 一些脚本
* `make-rules`: makefile 构建规则
* `os_pkrvars`: 各个操作系统特殊变量赋值
* `packer_templates`: packer模板定义
# 运行
## 构建vmware-iso的Ubuntu 16.04镜像
`PACKER_CACHE_DIR=/f/build_cache packer build -only=vmware-iso.vm -var-file ./os_pkrvars/ubuntu/ubuntu-16.04-x86_64.pkrvars.hcl -var output_directory=/f/build ./packer_templates/`
* `PACKER_CACHE_DIR`: 设置packer缓存目录,用于缓存下载的镜像仓库等。 默认是`./packer_cache`.
* `-var output_directory=/f/build`: 指定镜像输出目录。

## 构建vmware-vmx的Ubuntu 16.04镜像
`PACKER_CACHE_DIR=/f/build_cache packer build -only=vmware-vmx.vm -var is_golden_image_build=false -var-file ./os_pkrvars/ubuntu/ubuntu-16.04-x86_64.pkrvars.hcl -var output_directory=/f/build   ./packer_templates/`
*  `is_golden_image_build=false`: 必传，表明当前为基于黄金镜像构建其他镜像
* `-var-file ./os_pkrvars/ubuntu/ubuntu-16.04-x86_64.pkrvars.hcl`: 如果不通过`vmware_vmx_source_path`指定黄金镜像路径时，默认是源为`${local.output_directory}/${var.os_name}/${var.os_type}/${var.os_arch}.vmx`