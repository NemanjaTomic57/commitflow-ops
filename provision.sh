#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${VIRTUAL_ENV:-}" ]]; then
  echo "Error: Python virtual environment is not activated."
  exit 1
fi

terraform -chdir="${SCRIPT_DIR}/00_base" init
terraform -chdir="${SCRIPT_DIR}/00_base" apply -auto-approve -var-file secrets.tfvars

cd "${SCRIPT_DIR}/00_base/ansible"

python build_inventory.py
ansible-playbook -i inventory.yml playbook.yml

terraform -chdir="${SCRIPT_DIR}/01_ecs" init
terraform -chdir="${SCRIPT_DIR}/01_ecs" apply -auto-approve
