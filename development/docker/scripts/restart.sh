#!/usr/bin/env bash
set -euo pipefail

# Basic path elements definition.

readonly FILE_PATH="$(realpath ${BASH_SOURCE})"
readonly CURRENT_DIR="$(dirname ${FILE_PATH})"
readonly OPS_SCRIPT_DIRECTORY="$(realpath ${CURRENT_DIR}/../../../scripts/utils)"

# Color codes import

source "${OPS_SCRIPT_DIRECTORY}/colors.sh"

# Logger import

source "${OPS_SCRIPT_DIRECTORY}/log.sh"

bash "${OPS_SCRIPT_DIRECTORY}/header.sh" "$@"

# VitruviusLabs HEADER SCRIPT END

bash "${CURRENT_DIR}/down.sh" --no-header && bash "${CURRENT_DIR}/up.sh" --no-header
