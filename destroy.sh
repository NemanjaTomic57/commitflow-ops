#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

terraform -chdir="${SCRIPT_DIR}/01_ecs" apply -destroy -auto-approve

terraform -chdir="${SCRIPT_DIR}/00_base" apply -destroy -auto-approve -var-file secrets.tfvars
