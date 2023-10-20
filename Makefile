# .DEFAULT_GOAL为makefile自带变量, 用于设置默认目标
# https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
.DEFAULT_GOAL := help


.PHONY: all
all: format

include make-rules/common.mk # make sure include common.mk at the first include line
include make-rules/tools.mk
include make-rules/packer.mk


# Usage

define USAGE_OPTIONS

Options:
  PURPOSE				Specify custome build purpose. support purpose '$(PURPOSE_ALL)'. default is 'none'.
  PACKER_CACHE_DIR   	Change packer cache directory.
  DEBUG            		Whether to generate debug symbols and enable packer interactive build . Default is 0.
  ARCH             		Specify OS Arch. default: x86_64. support: 'x86_64' and 'aarch64'
  VARS             		Passing packer variables. For example: VARS="vmware-format=ova". check 'packer_templates/pkr-variables' for support variables
  FORCE            		Force packer build replace existing artifacts. Default is 0
  V                		Set to 1 enable verbose build and packer log. Default is 0.

endef
export USAGE_OPTIONS

## format: format all pkr.hcl and .pkrvars.hcl files.
.PHONY: format
format: tools.verify.packer
	@echo "===========> Formatting codes"
	@$(MAKE) packer.format

## deps: install build dependencies
.PHONY: deps
deps:
	@echo "===========> install build dependencies"
	@$(MAKE) packer.init


## help: Show this help info.
# 这里会提取target上一行的\#\#注释并生成到Makefile help文档中
.PHONY: help
help: Makefile
	@echo -e "\nUsage: make <TARGETS> <OPTIONS> ...\n\nTargets:"
	@sed -n 's/^##//p' $< | column -t -s ':' | sed -e 's/^/ /'
	@echo "$$USAGE_OPTIONS"

# ///////////////////////////////// template //////////////////////////////

# ---------  vmware-iso template -------------

VMWARE_TEMPLATE_OS_NAMES ?=  centos-7 centos-stream-8 centos-stream-9 \
					ubuntu-16.04  ubuntu-20.04 ubuntu-22.04 ubuntu-23.04

VMWARE_TEMPLATE_BUILD_TARGET := $(addprefix build.template.vmware-iso.,$(VMWARE_TEMPLATE_OS_NAMES))
VMWARE_TEMPLATE_VALIDATE_TARGET := $(addprefix validate.template.vmware-iso.,$(VMWARE_TEMPLATE_OS_NAMES))

## build-vmware-template-all: build all vmware-iso template with different os
##	build.template.vmware-iso.centos-7
##	build.template.vmware-iso.centos-stream-8
## 	build.template.vmware-iso.centos-stream-9
## 	build.template.vmware-iso.ubuntu-16.04
## 	build.template.vmware-iso.ubuntu-20.04
## 	build.template.vmware-iso.ubuntu-22.04
## 	build.template.vmware-iso.ubuntu-23.04
build-vmware-template-all: $(VMWARE_TEMPLATE_BUILD_TARGET)

## build-vmware-template-all: validate all vmware-iso template with different os
## 	validate.template.vmware-iso.centos-7
## 	validate.template.vmware-iso.centos-stream-8
## 	validate.template.vmware-iso.centos-stream-9
## 	validate.template.vmware-iso.ubuntu-16.04
## 	validate.template.vmware-iso.ubuntu-20.04
## 	validate.template.vmware-iso.ubuntu-22.04
## 	validate.template.vmware-iso.ubuntu-23.04
validate-vmware-template-all: $(VMWARE_TEMPLATE_VALIDATE_TARGET)



# ///////////////////////////////// custom image //////////////////////////////
#PURPOSE_KUBERNETES := kubernetes # install kubernetes
#URPOSE_GITLAB_RUNNER := gitlab-runner # gitlab-runner image

PURPOSE_ALL := none
ifeq ($(origin PURPOSE),undefined)
	PURPOSE ?= none
endif

# ---------  vmware-vmx custom-------------
VMWARE_VMX_CUSTOM_OS_NAMES ?=  centos-7 centos-stream-8 centos-stream-9 \
					ubuntu-16.04  ubuntu-20.04 ubuntu-22.04 ubuntu-23.04

NONE_VMWARE_VMX_CUSTOM_BUILD_TARGET := $(addprefix build.custom.$(PURPOSE_NONE).vmware-vmx.,$(VMWARE_CUSTOM_OS_NAMES))
NONE_VMWARE_VMX_CUSTOM_VALIDATE_TARGET := $(addprefix validate.custom.$(PURPOSE_NONE).vmware-vmx.,$(VMWARE_CUSTOM_OS_NAMES))

## build-vmware-vmx-none-custom-all: build custom image from vmware-vmx builder for none ( custom nothing ) purpose
## 	build.custom.none.vmware-vmx.centos-7
## 	build.custom.none.vmware-vmx.centos-stream-8
## 	build.custom.none.vmware-vmx.centos-stream-9
## 	build.custom.none.vmware-vmx.ubuntu-16.04
## 	build.custom.none.vmware-vmx.ubuntu-20.04
## 	build.custom.none.vmware-vmx.ubuntu-22.04
## 	build.custom.none.vmware-vmx.ubuntu-23.04
build-vmware-vmx-none-custom-all: $(NONE_VMWARE_VMX_CUSTOM_BUILD_TARGET)

## validate-vmware-vmx-none-custom-all: validate custom template
## 	validate.custom.none.vmware-vmx.centos-7
## 	validate.custom.none.vmware-vmx.centos-stream-8
## 	validate.custom.none.vmware-vmx.centos-stream-9
## 	validate.custom.none.vmware-vmx.ubuntu-16.04
## 	validate.custom.none.vmware-vmx.ubuntu-20.04
## 	validate.custom.none.vmware-vmx.ubuntu-22.04
## 	validate.custom.none.vmware-vmx.ubuntu-23.04
validate-vmware-vmx-none-custom-all: $(NONE_VMWARE_VMX_CUSTOM_VALIDATE_TARGET)


# ---------  alicloud-ecs custom-------------

ALICLOUD_CUSTOM_OS_NAMES ?=  centos-7 centos-stream-8 centos-stream-9 \
						ubuntu-20.04 ubuntu-22.04

ALICLOUD_CUSTOM_BUILD_TARGET := $(addprefix build.custom.$(PURPOSE).alicloud-ecs.,$(ALICLOUD_CUSTOM_OS_NAMES))
ALICLOUD_CUSTOM_VALIDATE_TARGET := $(addprefix validate.custom.$(PURPOSE).alicloud-ecs.,$(ALICLOUD_CUSTOM_OS_NAMES))

## build-alicloud-ecs-custom-all: build custom image from alicloud-ecs builder for  PURPOSE purpose
## 	build.custom.PURPOSE.alicloud-ecs.centos-7
## 	build.custom.PURPOSE.alicloud-ecs.centos-stream-8
## 	build.custom.PURPOSE.alicloud-ecs.centos-stream-9
## 	build.custom.PURPOSE.alicloud-ecs.ubuntu-16.04
## 	build.custom.PURPOSE.alicloud-ecs.ubuntu-20.04
## 	build.custom.PURPOSE.alicloud-ecs.ubuntu-22.04
## 	build.custom.PURPOSE.alicloud-ecs.ubuntu-23.04
build-alicloud-ecs-custom-all: $(ALICLOUD_CUSTOM_BUILD_TARGET)

## validate-alicloud-ecs-custom-all: validate custom template.
## 	validate.custom.PURPOSE.alicloud-ecs.centos-7
## 	validate.custom.PURPOSE.alicloud-ecs.centos-stream-8
## 	validate.custom.PURPOSE.alicloud-ecs.centos-stream-9
## 	validate.custom.PURPOSE.alicloud-ecs.ubuntu-20.04
## 	validate.custom.PURPOSE.alicloud-ecs.ubuntu-22.04
validate-alicloud-ecs-custom-all: $(ALICLOUD_CUSTOM_VALIDATE_TARGET)
