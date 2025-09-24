##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk '\
		BEGIN { \
			FS = ":.*##"; \
			printf "\nUsage:\n  make \033[36m<target>\033[0m\n" \
		} \
		/^[a-zA-Z_0-9-]+:.*?##/ { \
			target = $$1; \
			help_msg = $$2; \
			gsub(/`[^`]+`/, "\033[32m&\033[0m", help_msg); \
			gsub(/`/, "", help_msg); \
			printf "  \033[36m%-15s\033[0m %s\n", target, help_msg \
		} \
		/^##@/ { \
			printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
		} \
	' $(MAKEFILE_LIST)

CONTAINER_RUNTIME ?= $(shell \
	if command -v podman >/dev/null 2>&1; then echo podman; \
	elif command -v nerdctl >/dev/null 2>&1; then echo nerdctl; \
	elif command -v docker >/dev/null 2>&1; then echo docker; \
	else echo "no-runtime"; \
	fi)

ANSIBLE := ansible \
	-i inventory \
	--vault-id inventory/.vault_password

ANSIBLE_PLAYBOOK := ansible-playbook \
	-i inventory \
	--vault-id inventory/.vault_password \
	-e "@inventory/kubespray_vars.yaml"

ARGS ?= $(filter-out $@,$(MAKECMDGOALS))

CONTAINER_RUNTIME_RUN := $(CONTAINER_RUNTIME) run --rm -it \
	--mount type=bind,src=${PWD}/inventory,dst=/kubespray/inventory \
	--mount type=bind,src=${PWD}/playbooks,dst=/kubespray/playbooks/local \
	-e ANSIBLE_HOST_KEY_CHECKING=False \
	-e ANSIBLE_LOAD_CALLBACK_PLUGINS=True

KUBESPRAY_VERSION ?= v2.28.1

##@ Development

.PHONY: container
container: ## Run command in kubespray container. Usage: `make container '<command>'`
	$(CONTAINER_RUNTIME_RUN) \
		-e ANSIBLE_TIMEOUT=60 \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		$(ARGS)

.PHONY: vault
vault: ## Encrypt a string using ansible-vault. Usage: `make vault '<value>'`
	$(CONTAINER_RUNTIME_RUN) \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		ansible-vault encrypt_string --vault-id inventory/.vault_password '$(ARGS)'

.PHONY: ping
ping: ## Ping all nodes in the inventory.
	$(CONTAINER_RUNTIME_RUN) \
		-e ANSIBLE_TIMEOUT=60 \
		-e ANSIBLE_STDOUT_CALLBACK=ansible.builtin.minimal \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		$(ANSIBLE) -m ping all

.PHONY: exec
exec: ## Run command on all nodes in the inventory. Usage: `make exec '<command>'`
	$(CONTAINER_RUNTIME_RUN) \
		-e ANSIBLE_TIMEOUT=300 \
		-e ANSIBLE_STDOUT_CALLBACK=ansible.builtin.minimal \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		$(ANSIBLE) -m shell -b -a '$(ARGS)' all

.PHONY: reboot
reboot: ## Reboot all nodes in the inventory.
	$(CONTAINER_RUNTIME_RUN) \
		-e ANSIBLE_TIMEOUT=300 \
		-e ANSIBLE_STDOUT_CALLBACK=ansible.builtin.minimal \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		$(ANSIBLE) -m reboot -b all

.PHONY: create
create: ## Create a new cluster.
	$(CONTAINER_RUNTIME_RUN) \
		-e ANSIBLE_TIMEOUT=120 \
		-e ANSIBLE_STDOUT_CALLBACK=ansible.builtin.default \
		-e ANSIBLE_CALLBACK_RESULT_FORMAT=yaml \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		$(ANSIBLE_PLAYBOOK) -b cluster.yml

.PHONY: reset
reset: ## Reset an existing cluster.
	$(CONTAINER_RUNTIME_RUN) \
		-e ANSIBLE_TIMEOUT=120 \
		-e ANSIBLE_STDOUT_CALLBACK=ansible.builtin.default \
		-e ANSIBLE_CALLBACK_RESULT_FORMAT=yaml \
		quay.io/kubespray/kubespray:$(KUBESPRAY_VERSION) \
		$(ANSIBLE_PLAYBOOK) -b reset.yml

# Swallow extra MAKECMDGOALS so make doesn't try to build them
%:
	@:
