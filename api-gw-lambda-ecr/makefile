
.ONESHELL:
tf_apply:
	set -ex
	@cd 1_api_resources
	@echo $(hello_api_tag)
	# Simulate commit sha
	export TF_VAR_git_sha=$(shell echo -n $(date +%s) | sha256sum | tr -d "\n *-")
	# Deploy lambda functions
	terraform init
	terraform apply
	# Create hello_api alias if no alias exists
	./script.sh hello_api ${hello_api_tag}
