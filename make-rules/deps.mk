## --------------------------------------
## Dependencies
## --------------------------------------
##@ Dependencies

.PHONY: deps
deps: ## Installs/checks all dependencies
deps: deps-qemu

.PHONY: deps.vmware
deps.vmware:
	$(PACKER) init $(ROOT)
