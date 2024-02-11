#!/usr/bin/env bash
set -euo pipefail

# Basic path elements definition.

readonly FILE_PATH="$(realpath ${BASH_SOURCE})"
readonly CURRENT_DIR="$(dirname ${FILE_PATH})"
readonly OPS_SCRIPT_DIRECTORY="$(realpath ${CURRENT_DIR}/../../scripts)"

# Color codes import

source "${OPS_SCRIPT_DIRECTORY}/utils/colors.sh"

bash "${OPS_SCRIPT_DIRECTORY}/utils/header.sh" "$@"

# Logger import

source "${OPS_SCRIPT_DIRECTORY}/utils/log.sh"

# VitruviusLabs HEADER SCRIPT END

log "${COLOR_BLUE}Starting traefik environment initialisation...${COLOR_NONE}"

readonly DEVELOPMENT_DIRECTORY="$(realpath ${CURRENT_DIR}/..)"
readonly DOCKER_DEVELOPMENT_DIRECTORY="$(realpath ${DEVELOPMENT_DIRECTORY}/docker)"
readonly TRAEFIK_DIRECTORY="$(realpath ${DOCKER_DEVELOPMENT_DIRECTORY}/services/traefik)"

# example.env => .env

if ! [[ -f "${DOCKER_DEVELOPMENT_DIRECTORY}/.env" ]]; then

	log "${COLOR_YELLOW}File '.env' missing.${COLOR_BLUE} Creating...${COLOR_NONE}"

	cp "${DOCKER_DEVELOPMENT_DIRECTORY}/example.env" "${DOCKER_DEVELOPMENT_DIRECTORY}/.env"

	log "${COLOR_GREEN}File '.env'created.${COLOR_NONE} You can now edit it to your needs."

fi

source "${DOCKER_DEVELOPMENT_DIRECTORY}/.env"

# traefik.toml

if [[ -f "${TRAEFIK_DIRECTORY}/traefik.toml" ]]; then

	log "${COLOR_YELLOW}File 'traefik.toml' found.${COLOR_RED} Deleting...${COLOR_NONE}"

	rm -rf "${TRAEFIK_DIRECTORY}/traefik.toml"

	log "${COLOR_GREEN}File 'traefik.toml' deleted.${COLOR_NONE}"

fi

log "Creating 'traefik.toml'file.${COLOR_BLUE} Creating...${COLOR_NONE}"

cp "${TRAEFIK_DIRECTORY}/traefik.example.toml" "${TRAEFIK_DIRECTORY}/traefik.toml"

if [[ "${OSTYPE}" == "linux-gnu"* ]]; then

	sed -i'' -e "s/{{COMPANY_NAME}}=*/${COMPANY_NAME}/g" "${TRAEFIK_DIRECTORY}/traefik.toml"

elif [[ "${OSTYPE}" == "darwin"* ]]; then

	sed -i '' -e "s/{{COMPANY_NAME}}=*/${COMPANY_NAME}/g" "${TRAEFIK_DIRECTORY}/traefik.toml"

fi

log "${COLOR_GREEN}File 'traefik.toml'created.${COLOR_NONE}"

# domains.txt

if ! [[ -f "${TRAEFIK_DIRECTORY}/domains.txt" ]]; then

	log "${COLOR_YELLOW}File 'domains.txt' missing.${COLOR_BLUE} Creating...${COLOR_NONE}"

	cp "${TRAEFIK_DIRECTORY}/domains.example.txt" "${TRAEFIK_DIRECTORY}/domains.txt"

	if [[ "${OSTYPE}" == "linux-gnu"* ]]; then

		sed -i'' -e "s/{{COMPANY_NAME}}=*/${COMPANY_NAME}/g" "${TRAEFIK_DIRECTORY}/domains.txt"

	elif [[ "${OSTYPE}" == "darwin"* ]]; then

		sed -i '' -e "s/{{COMPANY_NAME}}=*/${COMPANY_NAME}/g" "${TRAEFIK_DIRECTORY}/domains.txt"

	fi

	log "${COLOR_GREEN}File 'domains.txt'created.${COLOR_NONE}"

fi

# certificates reset

log "${COLOR_YELLOW}Deleting all existing certificates...${COLOR_NONE}"

rm -rf "${TRAEFIK_DIRECTORY}/certificates"
mkdir "${TRAEFIK_DIRECTORY}/certificates"
touch "${TRAEFIK_DIRECTORY}/certificates/.dummy"

log "${COLOR_GREEN}Deleted all existing certificates.${COLOR_NONE}"

# domains consolidation

log "${COLOR_YELLOW}Consolidating 'domains.txt'...${COLOR_NONE}"

RAW_DOMAINS="$(cat ${TRAEFIK_DIRECTORY}/domains.txt)"
DOMAINS=(${RAW_DOMAINS//$'\n'/ })

for i in "${!DOMAINS[@]}"; do

	log "${COLOR_YELLOW}Handling domain '${DOMAINS[$i]}'...${COLOR_NONE}"

	bash "${CURRENT_DIR}/create_certificate.sh" --domain "${DOMAINS[$i]}"

	log "${COLOR_GREEN}Domain '${DOMAINS[$i]}' done.${COLOR_NONE}"

done

log "${COLOR_GREEN}Traefik environment ready!${COLOR_NONE}"
