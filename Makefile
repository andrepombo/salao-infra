TF=terraform
ENV?=prod
ENV_DIR=environments/$(ENV)

init:
	$(TF) -chdir=$(ENV_DIR) init

plan:
	$(TF) -chdir=$(ENV_DIR) plan -out tfplan

apply:
	$(TF) -chdir=$(ENV_DIR) apply tfplan

output:
	$(TF) -chdir=$(ENV_DIR) output
