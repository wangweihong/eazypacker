# ==============================================================================
# Makefile helper functions for tools
#

# Specify tools severity, include: BLOCKER_TOOLS, CRITICAL_TOOLS, TRIVIAL_TOOLS.
# Missing BLOCKER_TOOLS can cause the CI flow execution failed, i.e. `make all` failed.
# Missing CRITICAL_TOOLS can lead to some necessary operations failed. i.e. `make release` failed.
# TRIVIAL_TOOLS are Optional tools, missing these tool have no affect.
BLOCKER_TOOLS ?= packer
CRITICAL_TOOLS ?=
# 可选工具集，缺少不影响
TRIVIAL_TOOLS ?=

PACKER := packer

.PHONY: tools.install
tools.install: $(addprefix tools.install., $(TOOLS))

# 调用对应的工具规则安装工具
.PHONY: tools.install.%
tools.install.%:
	@echo "===========> Installing $*"
	@$(MAKE) install.$*

.PHONY: ensure.common.tools
ensure.common.tools:
	@$(ROOT_DIR)/hack/ensure_packer.sh

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


.PHONY: install.qemu-system-x86_64
install.emu-system-x86_64:
	@apt install qemu-system-x86