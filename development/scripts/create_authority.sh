#!/bin/bash
set -euo pipefail

FILE_PATH="$(realpath ${BASH_SOURCE})"
CURRENT_DIR="$(dirname ${FILE_PATH})"
DEVELOPMENT_DIRECTORY="$(realpath ${CURRENT_DIR}/..)"
DOCKER_DEVELOPMENT_DIRECTORY="$(realpath ${DEVELOPMENT_DIRECTORY}/docker)"
TRAEFIK_DIRECTORY="$(realpath ${DOCKER_DEVELOPMENT_DIRECTORY}/services/traefik)"

authorityDirectory="$(realpath ${TRAEFIK_DIRECTORY}/authority)"


parseargs() {
    # Define default values
    authorityDirectory=${authorityDirectory:-""}
	country=${country:-"FR"}
	state=${state:-"Ile-de-France"}
	locality=${locality:-"Paris"}
	organisation=${organisation:-"VitruviusLabs"}
	organisationalUnit=${organisationalUnit:-"IT Department"}
	commonName=${commonName:-"VitruviusLabs Local CA"}

    # Assign the values given by the user
    while [ $# -gt 0 ]; do
        if [[ $1 == *"--"* ]]; then
            param="${1/--/}"
            declare -g $param="$2"
        fi
        shift
    done
}

parseargs $@

if ! [[ -d "${authorityDirectory}" ]]; then
	echo "authorityDirectory not a directory: ${authorityDirectory}"
	exit 1
fi

AUTHORITY_KEY_PATH="${authorityDirectory}/certification_authority.key"
AUTHORITY_PEM_PATH="${authorityDirectory}/certification_authority.pem"

openssl genrsa -des3 -passout pass:root -out "${AUTHORITY_KEY_PATH}" 2048

openssl req -x509 \
			-new \
			-nodes \
			-key "${AUTHORITY_KEY_PATH}" \
			-sha256 \
			-days 1825 \
			-out "${AUTHORITY_PEM_PATH}" \
			-subj "/C=${country}/ST=${state}/L=${locality}/O=${organisation}/OU=${organisationalUnit}/CN=${commonName}" \
			-passout pass:root \
			-passin pass:root
