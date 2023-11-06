
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
PACKER_CACHE_DIR := $(ROOT_DIR)/cache
PACKER_CACHE_DIR_ENV = 
else
PACKER_CACHE_DIR_ENV = PACKER_CACHE_DIR=$(PACKER_OUTPUT_DIR)
endif

# packer操作系统变量
ifeq ($(origin OS_VARS_DIR),undefined)
OS_VARS_DIR := $(ROOT_DIR)/os_pkrvars
endif


ifeq ($(PACKER_FORCE), true)
  PACKER_FORCE_ARG = --force=true
endif

ifeq ($(PACKER_INTERACTIVE), true)
  PACKER_DEBUG_ARG = --debug=true
endif

ifdef DEBUG
 PACKER_LOG_ARG = PACKER_LOG=1
endif

PACKER_FORCE  ?= false
PACKER_OS_NAME ?= ubuntu
PACKER_OS_VERSION ?= 20.04
PACKER_OS_ARCH ?= x86_64
PACKER_TEMPLATE_SOURCE ?= vmware-iso
PACKER_CUSTOM_SOURCE ?= vmware-vmx


PACKER_ENVVARS = $(PACKER_CACHE_DIR_ENV) $(PACKER_LOG_ARG)

PACKER_VARS =  $(PACKER_FORCE_ARG) $(PACKER_DEBUG_ARG) \
	-var output_dir=$(PACKER_OUTPUT_DIR)

PACKER_VAR_FILES = -var-file=$(OS_VARS_DIR)/$(PACKER_OS_NAME)/$(PACKER_OS_NAME)-$(PACKER_OS_VERSION)-$(PACKER_OS_ARCH).pkrvars.hcl

# 列出所有 .hcl 文件
HCL_FILES := $(shell $(FIND) -type f -name '*.hcl')

.PHONY: packer.verify
packer.verify: tools.verify.packer $(addprefix packer.verify., $(subst /,=,$(HCL_FILES)))

.PHONY: packer.verify.%
packer.verify.%:
	$(eval FILE_PATH_PARA := $(patsubst packer.verify.%,%,$@))
	$(eval FILE_PATH := $(subst =,/,$(FILE_PATH_PARA)))
	@if [ -f $(FILE_PATH) ]; then \
        echo "====> Validating $(FILE_PATH)"; \
        packer validate -syntax-only $(FILE_PATH); \
    fi

.PHONY: packer.format
packer.format:
	$(PACKER) fmt -recursive $(ROOT_DIR) 

.PHONY: packer.init
packer.init:
	$(PACKER) init $(PACKER_TEMPLATE_DIR)

.PHONY: packer.build.template
packer.build.template: 
	$(PACKER_ENVVARS) $(PACKER) build -only=global_image.$(PACKER_TEMPLATE_SOURCE).vm $(PACKER_VARS) $(PACKER_VAR_FILES) $(PACKER_TEMPLATE_DIR)

.PHONY: packer.build.custom
packer.build.custom: 
	$(PACKER_ENVVARS) $(PACKER) build -only=custom_image.$(PACKER_TEMPLATE_SOURCE).vm $(PACKER_VARS) $(PACKER_VAR_FILES)  $(PACKER_TEMPLATE_DIR)


.PHONY: packer.inspect
packer.inspect: 
	$(PACKER) inspect $(PACKER_VARS) $(PACKER_VAR_FILES)  $(PACKER_TEMPLATE_DIR)

.PHONY: packer.validate
packer.validate: 
	$(PACKER) validate  $(PACKER_VAR_FILES)  $(PACKER_TEMPLATE_DIR)