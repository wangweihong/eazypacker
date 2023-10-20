
# Defining the canonical location of the Packer binary which will be used for
# `packer init`, `packer build` and `packer validate` commands.
PACKER=$(shell if [ $$(command -v packer | grep -v sbin) ]; then echo $$(command -v packer); else echo $(CURDIR)/.local/bin/packer; fi)

# packer模板目录
ifeq ($(origin PACKER_TEMPLATE_DIR),undefined)
PACKER_TEMPLATE_DIR := $(ROOT_DIR)/packer_templates
endif

# packer输出目录
ifeq ($(origin PACKER_OUTPUT_DIR),undefined)
PACKER_OUTPUT_DIR := $(ROOT_DIR)/output
endif

# packer缓存目录
ifeq ($(origin PACKER_CACHE_DIR),undefined)
PACKER_CACHE_DIR_ENV = 
else
PACKER_CACHE_DIR_ENV = PACKER_CACHE_DIR=$(PACKER_CACHE_DIR)
endif

# packer操作系统变量
ifeq ($(origin OS_VARS_DIR),undefined)
OS_VARS_DIR := $(ROOT_DIR)/os_pkrvars
endif


ifeq ($(FORCE), 1)
	PACKER_FORCE_ARG = --force=true
endif

ifdef DEBUG
	PACKER_DEBUG_ARG = --debug=true
endif

ifdef V
	PACKER_LOG_ARG = PACKER_LOG=1
endif

ifeq ($(origin ARCH),undefined)
	ARCH ?= x86_64
endif

# 将"A=b C=D"转换成"-var A=b -var C=D"
ifeq ($(strip $(VARS)),)
PACKER_VARS :=
else
PACKER_VARS := -var $(subst "$(SPACE)"," -var ",$(VARS))
endif

PACKER_ENVVARS = $(PACKER_CACHE_DIR_ENV) $(PACKER_LOG_ARG)


PACKER_VAR_FILES = -var-file=$(OS_VARS_DIR)/$(PACKER_OS_NAME)/$(PACKER_OS_NAME)-$(PACKER_OS_VERSION)-$(ARCH).pkrvars.hcl

# 列出所有 .hcl 文件
HCL_FILES := $(shell $(FIND) -type f -name '*.hcl')

# .PHONY: packer.verify
# packer.verify: tools.verify.packer $(addprefix packer.verify., $(subst /,=,$(HCL_FILES)))

# .PHONY: packer.verify.%
# packer.verify.%:
# 	$(eval FILE_PATH_PARA := $(patsubst packer.verify.%,%,$@))
# 	$(eval FILE_PATH := $(subst =,/,$(FILE_PATH_PARA)))
# 	@if [ -f $(FILE_PATH) ]; then \
#         echo "====> Validating $(FILE_PATH)"; \
#         packer validate -syntax-only $(FILE_PATH); \
#     fi

.PHONY: packer.format
packer.format:
	$(PACKER) fmt -recursive $(ROOT_DIR) 




# make inspect.template.hyperv.ubuntu_16.04
# make inspect.template.parallels-iso.ubuntu_16.04
.PHONY: inspect.template.%
inspect.template.%: tools.verify.packer
	$(eval SOURCE_TYPE := $(word 1,$(subst ., ,$*)))
	$(eval OS_VERSION := $(subst $(SOURCE_TYPE).,,$*))
	$(eval OS_NAME := $(word 1, $(subst -, ,$(OS_VERSION))))

	@echo "===========> Inspect template $(SOURCE_TYPE).$(OS_VERSION)-$(ARCH) with VARS $(VARS)"
	$(PACKER) inspect -only=golden_image.$(SOURCE_TYPE).vm $(PACKER_VARS) -var-file=$(OS_VARS_DIR)/$(OS_NAME)/$(OS_VERSION)-$(ARCH).pkrvars.hcl $(PACKER_TEMPLATE_DIR)

# make validate.template.hyperv.ubuntu_16.04
# make validate.template.parallels-iso.ubuntu_16.04
.PHONY: validate.template.%
validate.template.%: tools.verify.packer
	$(eval SOURCE_TYPE := $(word 1,$(subst ., ,$*)))
	$(eval OS_VERSION := $(subst $(SOURCE_TYPE).,,$*))
	$(eval OS_NAME := $(word 1, $(subst -, ,$(OS_VERSION))))
	@echo "===========> Validate template $(SOURCE_TYPE).$(OS_VERSION)-$(ARCH) with VARS $(VARS)"
	$(PACKER) validate -only=golden_image.$(SOURCE_TYPE).vm $(PACKER_VARS) -var-file=$(OS_VARS_DIR)/$(OS_NAME)/$(OS_VERSION)-$(ARCH).pkrvars.hcl $(PACKER_TEMPLATE_DIR)

# make build.template.hyperv.ubuntu_16.04
.PHONY: build.template.%
build.template.%: validate.template.%
	$(eval SOURCE_TYPE := $(word 1,$(subst ., ,$*)))
	$(eval OS_VERSION := $(subst $(SOURCE_TYPE).,,$*))
	$(eval OS_NAME := $(word 1, $(subst -, ,$(OS_VERSION))))
	@echo "===========> Build template $(SOURCE_TYPE).$(OS_VERSION)-$(ARCH) with VARS $(VARS)"
	$(PACKER_ENVVARS) $(PACKER) build -only=golden_image.$(SOURCE_TYPE).vm $(PACKER_DEBUG_ARG) $(PACKER_FORCE_ARG) $(PACKER_VARS) -var-file=$(OS_VARS_DIR)/$(OS_NAME)/$(OS_VERSION)-$(ARCH).pkrvars.hcl $(PACKER_TEMPLATE_DIR)

# make inspect.custom.kubernetes.qemu.ubuntu_16.04
.PHONY: inspect.custom.%
inspect.custom.%: tools.verify.packer
	$(eval COMPONENTS := $(subst ., ,$(patsubst validate.custom.%,%,$@)))
	$(eval CUSTOM_PURPOSE := $(word 1, $(COMPONENTS)))
	$(eval SOURCE_TYPE :=$(word 2, $(COMPONENTS)))
	$(eval OS_VERSION := $(subst $(CUSTOM_PURPOSE).$(SOURCE_TYPE).,,$*))
	$(eval OS_NAME := $(word 1, $(subst -, ,$(OS_VERSION))))

	@echo "===========> Inspect custom $(SOURCE_TYPE).$(OS_VERSION)-$(ARCH) for $(CUSTOM_PURPOSE) with VARS $(VARS)"
	$(PACKER) inspect -only=custom_image.$(SOURCE_TYPE).vm  $(PACKER_VARS) -var custom_purpose=$(CUSTOM_PURPOSE) -var-file=$(OS_VARS_DIR)/$(OS_NAME)/$(OS_VERSION)-$(ARCH).pkrvars.hcl $(PACKER_TEMPLATE_DIR)

# make validate.custom.kubernetes.qemu.ubuntu_16.04
.PHONY: validate.custom.%
validate.custom.%: tools.verify.packer
	$(eval COMPONENTS := $(subst ., ,$(patsubst validate.custom.%,%,$@)))
	$(eval CUSTOM_PURPOSE := $(word 1, $(COMPONENTS)))
	$(eval SOURCE_TYPE :=$(word 2, $(COMPONENTS)))
	$(eval OS_VERSION := $(subst $(CUSTOM_PURPOSE).$(SOURCE_TYPE).,,$*))
	$(eval OS_NAME := $(word 1, $(subst -, ,$(OS_VERSION))))

	@echo "===========> Validate custom $(SOURCE_TYPE).$(OS_VERSION)-$(ARCH) for $(CUSTOM_PURPOSE) with VARS $(VARS)"
	$(PACKER) validate -only=custom_image.$(SOURCE_TYPE).vm $(PACKER_VARS) -var custom_purpose=$(CUSTOM_PURPOSE) -var-file=$(OS_VARS_DIR)/$(OS_NAME)/$(OS_VERSION)-$(ARCH).pkrvars.hcl $(PACKER_TEMPLATE_DIR)


# make build.custom.kubernetes.qemu.ubuntu-16.04
.PHONY: build.custom.%
build.custom.%: tools.verify.packer
	$(eval COMPONENTS := $(subst ., ,$(patsubst build.custom.%,%,$@)))
	$(eval CUSTOM_PURPOSE := $(word 1, $(COMPONENTS)))
	$(eval SOURCE_TYPE :=$(word 2, $(COMPONENTS)))
	$(eval OS_VERSION := $(subst $(CUSTOM_PURPOSE).$(SOURCE_TYPE).,,$*))
	$(eval OS_NAME := $(word 1, $(subst -, ,$(OS_VERSION))))

	@echo "===========> Build custom $(SOURCE_TYPE).$(OS_VERSION)-$(ARCH) for $(CUSTOM_PURPOSE) with VARS $(VARS)"
	$(PACKER_ENVVARS) $(PACKER) build -only=custom_image.$(SOURCE_TYPE).vm $(PACKER_DEBUG_ARG) $(PACKER_FORCE_ARG) $(PACKER_VARS) -var custom_purpose=$(CUSTOM_PURPOSE) -var-file=$(OS_VARS_DIR)/$(OS_NAME)/$(OS_VERSION)-$(ARCH).pkrvars.hcl $(PACKER_TEMPLATE_DIR)