# Dev Environment Variable Values
# These override defaults and provide environment-specific configuration.
# Do NOT commit sensitive values (ssh_public_key) — pass via CI/CD secrets or -var flag.

environment  = "dev"
location     = "eastus"
region_short = "eus"
project_name = "challenge"

# ssh_public_key: Set this to your public key content, e.g.:
# ssh_public_key = "ssh-rsa AAAA...your-key-here... user@host"
# In CI/CD: pass via TF_VAR_ssh_public_key environment variable

extra_tags = {
  # Additional optional tags for dev environment
  CostCenter  = "dev-workloads"
  Owner       = "opella"
  Environment = "dev"
}
