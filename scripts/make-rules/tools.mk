# ==============================================================================
# Makefile helper functions for tools
#

.PHONY: tools.install
tools.install: $(addprefix tools.install., $(TOOLS))

# 调用对应的工具规则安装工具
.PHONY: tools.install.%
tools.install.%:
	@echo "===========> Installing $*"
	@$(MAKE) install.$*

# 如果指定的工具不存在, 则进行安装
.PHONY: tools.verify.%
tools.verify.%:
	@if ! which $* &>/dev/null; then $(MAKE) tools.install.$*; fi

.PHONY: install.packer
install.packer:
	@wget https://releases.hashicorp.com/packer/1.9.4/packer_1.9.4_linux_amd64.zip
	@unzip ./packer_1.9.4_linux_amd64.zip
	@chmod +x ./packer
	@mv ./packer /usr/bin