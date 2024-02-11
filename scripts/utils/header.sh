#!/usr/bin/env bash
set -euo pipefail

# Basic path elements definition.

readonly FILE_PATH="$(realpath ${BASH_SOURCE})"
readonly CURRENT_DIR="$(dirname ${FILE_PATH})"

# Color codes import

source "${CURRENT_DIR}/colors.sh"

# Script parameter handling.

HEADER=true

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -z|--no-header) HEADER=false; shift ;;
        # *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

if [[ $HEADER == true ]]; then

	cat << EOF

${COLOR_BLUE}╔══════════════════════════════════════════════════════════════════╗${COLOR_NONE}
${COLOR_BLUE}║${COLOR_NONE}        _ _                    _              __       _          ${COLOR_BLUE}║${COLOR_NONE}
${COLOR_BLUE}║${COLOR_NONE} /\   /(_) |_ _ __ _   ___   _(_)_   _ ___   / /  __ _| |__  ___  ${COLOR_BLUE}║${COLOR_NONE}
${COLOR_BLUE}║${COLOR_NONE} \ \ / / | __| '__| | | \ \ / / | | | / __| / /  / _' | '_ \/ __| ${COLOR_BLUE}║${COLOR_NONE}
${COLOR_BLUE}║${COLOR_NONE}  \ V /| | |_| |  | |_| |\ V /| | |_| \__ \/ /__| (_| | |_) \__ \ ${COLOR_BLUE}║${COLOR_NONE}
${COLOR_BLUE}║${COLOR_NONE}   \_/ |_|\__|_|   \__,_| \_/ |_|\__,_|___/\____/\__,_|_.__/|___/ ${COLOR_BLUE}║${COLOR_NONE}
${COLOR_BLUE}║${COLOR_NONE}                                                                  ${COLOR_BLUE}║${COLOR_NONE}
${COLOR_BLUE}╚══════════════════════════════════════════════════════════════════╝${COLOR_NONE}

EOF

fi
