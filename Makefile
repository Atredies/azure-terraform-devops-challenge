# Azure Terraform Challenge — Convenience Makefile
# All targets run from the project root (azure-terraform-devops-challenge/)
#
# Prerequisites:
#   - terraform >= 1.5.0
#   - tflint >= v0.50.0 (brew install tflint / snap install tflint)
#   - checkov >= 3.x (pip install checkov)
#   - terraform-docs >= 0.17.0 (brew install terraform-docs)
#
# Usage:
#   make fmt           # Format all Terraform files
#   make lint          # Run tflint on all modules and environments
#   make validate      # Validate all environments
#   make plan-dev      # Run terraform plan for dev (requires Azure auth)
#   make plan-prod     # Run terraform plan for prod (requires Azure auth)
#   make docs          # Generate/update module READMEs with terraform-docs
#   make security-scan # Run checkov security analysis
#   make all-checks    # Run fmt + lint + validate + security-scan

SHELL := /bin/bash
.PHONY: all fmt lint validate plan-dev plan-prod docs security-scan clean all-checks help

MODULES_DIR    := modules
ENVS_DIR       := environments
TF_DOCS_CFG    := .terraform-docs.yml
TFLINT_CFG     := .tflint.hcl
CHECKOV_OUTPUT := .checkov-results

## help: Show this help message
help:
	@echo "Azure Terraform Challenge — Available targets:"
	@grep -E '^## ' Makefile | sed 's/## /  /'

## fmt: Format all Terraform files (terraform fmt -recursive)
fmt:
	@echo "==> Running terraform fmt..."
	terraform fmt -recursive .
	@echo "Done."

## fmt-check: Check formatting without writing (used in CI)
fmt-check:
	@echo "==> Checking terraform fmt..."
	terraform fmt -check -recursive -diff .

## lint: Run tflint on all modules and environments
lint:
	@echo "==> Initialising tflint plugins..."
	tflint --init
	@echo "==> Linting modules..."
	@for mod in $(MODULES_DIR)/*/; do \
		echo "  Linting $$mod"; \
		tflint --chdir="$$mod" --config="../../$(TFLINT_CFG)"; \
	done
	@echo "==> Linting environments..."
	@for env in $(ENVS_DIR)/*/; do \
		echo "  Linting $$env"; \
		tflint --chdir="$$env" --config="../../$(TFLINT_CFG)"; \
	done
	@echo "Done."

## validate: Run terraform validate on all environments
validate:
	@echo "==> Validating environments (no backend)..."
	@for env in $(ENVS_DIR)/*/; do \
		echo "  Validating $$env"; \
		terraform -chdir="$$env" init -backend=false -reconfigure -input=false > /dev/null; \
		terraform -chdir="$$env" validate; \
	done
	@echo "Done."

## plan-dev: Run terraform plan for dev environment (requires Azure auth + ssh_public_key)
plan-dev:
	@echo "==> Planning dev environment..."
	@echo "NOTE: Requires Azure credentials in environment (ARM_* vars or logged-in az cli)"
	terraform -chdir="$(ENVS_DIR)/dev" init
	terraform -chdir="$(ENVS_DIR)/dev" plan \
		-var-file=terraform.tfvars \
		-out=tfplan-dev
	@echo "Plan saved to $(ENVS_DIR)/dev/tfplan-dev"

## plan-prod: Run terraform plan for prod environment (requires Azure auth + ssh_public_key)
plan-prod:
	@echo "==> Planning prod environment..."
	@echo "NOTE: Requires Azure credentials in environment (ARM_* vars or logged-in az cli)"
	terraform -chdir="$(ENVS_DIR)/prod" init
	terraform -chdir="$(ENVS_DIR)/prod" plan \
		-var-file=terraform.tfvars \
		-out=tfplan-prod
	@echo "Plan saved to $(ENVS_DIR)/prod/tfplan-prod"

## docs: Generate module READMEs using terraform-docs
docs:
	@echo "==> Generating terraform-docs for all modules..."
	@for mod in $(MODULES_DIR)/*/; do \
		echo "  Documenting $$mod"; \
		terraform-docs "$$mod"; \
	done
	@echo "Done."

## security-scan: Run checkov security analysis on all Terraform code
security-scan:
	@echo "==> Running checkov security scan..."
	mkdir -p $(CHECKOV_OUTPUT)
	checkov -d . \
		--framework terraform \
		--output cli \
		--output sarif \
		--output-file-path $(CHECKOV_OUTPUT) \
		--soft-fail
	@echo "Results written to $(CHECKOV_OUTPUT)/"
	@echo "Done."

## all-checks: Run all checks (fmt-check, lint, validate, security-scan)
all-checks: fmt-check lint validate security-scan
	@echo "==> All checks complete."

## clean: Remove local Terraform state files, plan files, and cache
clean:
	@echo "==> Cleaning Terraform artifacts..."
	find . -name "*.tfplan" -delete
	find . -name "tfplan-*" -delete
	find . -name ".terraform.lock.hcl" -delete
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	rm -rf $(CHECKOV_OUTPUT)
	@echo "Done."
