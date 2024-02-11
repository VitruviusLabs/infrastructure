#!/usr/bin/env bash
set -euo pipefail

# Basic path elements definition.

readonly FILE_PATH="$(realpath ${BASH_SOURCE})"
readonly CURRENT_DIR="$(dirname ${FILE_PATH})"
readonly DEVELOPMENT_DOCKER_DIRECTORY="$(realpath ${CURRENT_DIR}/..)"
readonly OPS_SCRIPT_DIRECTORY="$(realpath ${DEVELOPMENT_DOCKER_DIRECTORY}/../../scripts/utils)"

# Color codes import

source "${OPS_SCRIPT_DIRECTORY}/colors.sh"

bash "${OPS_SCRIPT_DIRECTORY}/header.sh" "$@"

# Logger import

source "${OPS_SCRIPT_DIRECTORY}/log.sh"

# Environment import

source "${DEVELOPMENT_DOCKER_DIRECTORY}/.env"

# VitruviusLabs HEADER SCRIPT END

log "${COLOR_BLUE}Shutting down 'traefik infrastructure'...${COLOR_NONE}"
echo ""

docker compose -f "${DEVELOPMENT_DOCKER_DIRECTORY}"/docker-compose.yml -p "${COMPANY_NAME}-infrastructure" down

log "${COLOR_GREEN}Project '${COMPANY_NAME}-infrastructure' shutdown.${COLOR_NONE}"
