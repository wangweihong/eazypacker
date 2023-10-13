# .DEFAULT_GOAL为makefile自带变量, 用于设置默认目标
# https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
.DEFAULT_GOAL := all


.PHONY: all
all: 

include scripts/make-rules/common.mk # make sure include common.mk at the first include line

# Usage

define USAGE_OPTIONS

Options:
  DEBUG            Whether to generate debug symbols. Default is 0.
  V                Set to 1 enable verbose build. Default is 0.
endef
export USAGE_OPTIONS

## help: Show this help info.
# 这里会提取target上一行的\#\#注释并生成到Makefile help文档中
.PHONY: help
help: Makefile
	@echo -e "\nUsage: make <TARGETS> <OPTIONS> ...\n\nTargets:"
	@sed -n 's/^##//p' $< | column -t -s ':' | sed -e 's/^/ /'
	@echo "$$USAGE_OPTIONS"
