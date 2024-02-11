#!/usr/bin/env bash

set -euo pipefail

FILE_PATH="$(realpath ${BASH_SOURCE})"
CURRENT_DIR="$(dirname ${FILE_PATH})"
DEVELOPMENT_DIRECTORY="$(realpath ${CURRENT_DIR}/..)"
DOCKER_DEVELOPMENT_DIRECTORY="$(realpath ${DEVELOPMENT_DIRECTORY}/docker)"
TRAEFIK_DIRECTORY="$(realpath ${DOCKER_DEVELOPMENT_DIRECTORY}/services/traefik)"
TRAEFIK_CONFIGURATION_FILE="${TRAEFIK_DIRECTORY}/traefik.toml"

if ! [[ -f "${TRAEFIK_CONFIGURATION_FILE}" ]]; then
	echo "Traefik configuration file not found (traefik.toml): ${TRAEFIK_CONFIGURATION_FILE}"
fi

domain=""
CAKeyPath="${TRAEFIK_DIRECTORY}/authority/certification_authority.key"
CAPemPath="${TRAEFIK_DIRECTORY}/authority/certification_authority.pem"
certificatesDir="${TRAEFIK_DIRECTORY}/certificates"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--domain) domain="$2"; shift ;;
        -k|--CAKeyPath) CAKeyPath="$2"; shift ;;
        -c|--CAPemPath) CAPemPath="$2"; shift ;;
        -o|--certificatesDir) certificatesDir="$2" ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ "${domain}" == "" ]]; then
	echo "domain not defined"
	exit 1
fi

if ! [[ -f "${CAKeyPath}" ]]; then
	echo "CA key not a file"
	exit 1
fi

if ! [[ -f "${CAPemPath}" ]]; then
	echo "CA pem not a file"
	exit 1
fi

if ! [[ -d "${certificatesDir}" ]]; then
	echo "certificatesDir not a directory: ${certificatesDir}"
	exit 1
fi

DOMAIN_CERTIFICATES_DIRECTORY="${certificatesDir}/${domain}"

if ! [[ -d "${DOMAIN_CERTIFICATES_DIRECTORY}" ]]; then

	mkdir "${DOMAIN_CERTIFICATES_DIRECTORY}"

fi

DOMAIN_CERTIFICATE_KEY="${DOMAIN_CERTIFICATES_DIRECTORY}/${domain}.key"

if [[ -f "${DOMAIN_CERTIFICATE_KEY}" ]]; then

	rm "${DOMAIN_CERTIFICATE_KEY}"

fi

openssl genrsa -out "${DOMAIN_CERTIFICATE_KEY}" 2048

DOMAIN_CERTIFICATE_CSR="${DOMAIN_CERTIFICATES_DIRECTORY}/${domain}.csr"

if [[ -f "${DOMAIN_CERTIFICATE_CSR}" ]]; then

	rm "${DOMAIN_CERTIFICATE_CSR}"

fi

openssl req -new \
			-key "${DOMAIN_CERTIFICATE_KEY}" \
			-out "${DOMAIN_CERTIFICATE_CSR}" \
			-subj "/C=FR/ST=Ile-de-France/L=Paris/O=VitruviusLabs/OU=IT Department/CN=VitruviusLabs" \
			-passout pass:root \
			-passin pass:root


DOMAIN_CERTIFICATE_EXT="${DOMAIN_CERTIFICATES_DIRECTORY}/${domain}.ext"

if [[ -f "${DOMAIN_CERTIFICATE_EXT}" ]]; then

	rm "${DOMAIN_CERTIFICATE_EXT}"

fi

cat > "${DOMAIN_CERTIFICATE_EXT}" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${domain}

EOF

DOMAIN_CERTIFICATE="${DOMAIN_CERTIFICATES_DIRECTORY}/${domain}.crt"

if [[ -f "${DOMAIN_CERTIFICATE}" ]]; then

	rm "${DOMAIN_CERTIFICATE}"

fi

openssl x509 -req \
	-in "${DOMAIN_CERTIFICATE_CSR}" \
	-CA "${CAPemPath}" \
	-CAkey "${CAKeyPath}" \
	-CAcreateserial \
	-out "${DOMAIN_CERTIFICATE}" \
	-days 825 \
	-sha256 \
	-extfile "${DOMAIN_CERTIFICATE_EXT}" \
	-passin pass:root

rm "${DOMAIN_CERTIFICATE_CSR}"
rm "${DOMAIN_CERTIFICATE_EXT}"

cat << EOF >> $TRAEFIK_CONFIGURATION_FILE
[[tls.certificates]]
  certFile = "/etc/traefik/certificates/${domain}/${domain}.crt"
  keyFile = "/etc/traefik/certificates/${domain}/${domain}.key"
EOF
