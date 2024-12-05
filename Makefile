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

##@ Development

.PHONY: backup-secret
backup-secret: ## Backup local secret files.
	tar -czvf `date "+%Y-%m-%d-%H"`_local_secret.tar.gz local_secret

.PHONY: encrypt
encrypt: ## Encrypt secret for terraform. Usage: `make encrypt secret=<value>`
	@printf "$(secret)" \
		| openssl pkeyutl -encrypt -pubin -inkey public.pem \
		| base64 \
		| tr -d '\n'\
		| xargs -0 echo

.PHONY: decrypt
decrypt: ## Decrypt secret for terraform. Usage: `make decrypt secret=<encryptedSecret>`
	@printf "$(secret)" \
		| base64 -d \
		| openssl pkeyutl -decrypt -inkey private.pem \
		| xargs -0 echo
