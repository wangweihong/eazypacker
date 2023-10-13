
SHELL := /bin/bash
OLD_SHELL := $(SHELL)
SHELL = $(OLD_SHELL)

# Makefile settings
ifndef V
MAKEFLAGS += --no-print-directory
endif

ifdef DEBUG
# https://www.cmcrossroads.com/article/tracing-rule-execution-gnu-make
# replace shell with debug Makefile log
SHELL = $(warning Building $@$(if $<, (from $<))$(if $?, ($? newer)))$(OLD_SHELL) -x
endif

## include the common make file
## MAKEFILE_LIST: makefile自带的环境变量，包含所有的makefile文件
COMMON_SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# 代码目录
ifeq ($(origin ROOT_DIR),undefined)
ROOT_DIR := $(abspath $(shell cd $(COMMON_SELF_DIR)/../.. && pwd -P))
endif


# set the version number. you should not need to do this
# for the majority of scenarios.
ifeq ($(origin VERSION), undefined)
VERSION := $(shell git describe --tags --always --match='v*')
endif
# Check if the tree is dirty.  default to dirty
GIT_TREE_STATE:="dirty"
ifeq (, $(shell git status --porcelain 2>/dev/null))
	GIT_TREE_STATE="clean"
endif
GIT_COMMIT:=$(shell git rev-parse HEAD)




#	# 保证脚本换行符为\n,CRLF-->LF
#	#CHANGE_HOOK_LINE_SPERATOR = $(shell dos2unix ./scripts/githooks/* )
#	CHANGE_HOOK_LINE_SPERATOR = $(shell find ./scripts/githooks -type f -exec sh -c 'tr -d "\r" < "$0" > "$0.tmp" && mv "$0.tmp" "$0"' {} \; )
#	# 保证脚本可执行
MAKE_HOOK_EXECUTABLE:= $(shell chmod +x ./scripts/githooks/*)
#    # Copy githook scripts when execute makefile
    # 采取这种方式, 可以实现git hook的统一和强制. 当执行Make任意规则时,强制进行拷贝。因此不需要单独的规则来拷贝
COPY_GITHOOK:=$(shell mkdir -p .git/hooks/ && cp -f ./scripts/githooks/* .git/hooks/)

COMMA := ,
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)

