#!/usr/bin/env bash
set -euo pipefail

function log() {
	local color_black="$(tput setaf 0)"
	local color_red="$(tput setaf 1)"
	local color_green="$(tput setaf 2)"
	local color_yellow="$(tput setaf 3)"
	local color_blue="$(tput setaf 4)"
	local color_mangenta="$(tput setaf 5)"
	local color_cyan="$(tput setaf 6)"
	local color_white="$(tput setaf 7)"
	local color_none="$(tput sgr0)"

	local prefix="[${color_blue}VitruviusLabs${color_none}] "
	local date_format="%Y-%m-%d_%T"
	local current_date="[$(date +${date_format})]"

	if [[ "$#" -eq 0 ]]; then

		echo "${prefix}${current_date} ${color_red}No argument to print.${color_none}"

	else

		echo "${prefix}${current_date} $@"

	fi
}
