
.ONESHELL:
tf_apply:
	set -ex
	@echo $(hello_api_tag)
	# Simulate commit sha
	export TF_VAR_hello_api_tag=$(hello_api_tag)
	export TF_VAR_git_sha=$(shell date +%s | sha256sum | tr -d "\n *-")
	# Deploy lambda functions
	terraform init
	terraform apply
