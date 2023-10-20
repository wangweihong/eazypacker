
# Defining the canonical location of the Packer binary which will be used for
# `packer init`, `packer build` and `packer validate` commands.
PACKER=$(shell if [ $$(command -v packer | grep -v sbin) ]; then echo $$(command -v packer); else echo $(CURDIR)/.local/bin/packer; fi)


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
