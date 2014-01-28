#!/bin/bash

# Default config vars
CURL="$(which curl)"
PUSHOVER_URL="https://api.pushover.net/1/messages.json"
TOKEN="" # May be set in pushover.conf or given on command line
USER="" # May be set in pushover.conf or given on command line

# Load user config
CONFIG_FILE="${XDG_CONFIG_HOME-${HOME}/.config}/pushover.conf"
if [ -e "${CONFIG_FILE}" ]; then
    . ${CONFIG_FILE}
else
    echo "Can't find ${CONFIG_FILE}: You must create it before using this script" >&2
    exit 1
fi

# Functions used elsewhere in this script
usage() {
    echo "${0} <options> <message>"
    echo " -d <device>"
    echo " -D <timestamp>"
    echo " -p <priority>"
    echo " -t <title>"
    echo " -T <TOKEN>"
    echo " -s <sound>"
    echo " -u <url>"
    echo " -U <USER>"
    echo " -a <url_title>"
    exit 1
}
opt_field() {
    field=$1
    shift
    value="${*}"
    if [ ! -z "${value}" ]; then
        echo "-F \"${field}=${value}\""
    fi
}
validate_user_token() {
	field="${1}"
	value="${2}"
	opt="${3}"
	ret=1
	if [ -z "${value}" ]; then
		echo "${field} is unset or empty: Did you create ${CONFIG_FILE} or specify ${opt} on the command line?" >&2
	elif ! echo "${value}" | egrep -q '[A-Za-z0-9]{30}'; then
		echo "Value of ${field}, \"${value}\", does not match expected format. Should be 30 characters of A-Z, a-z and 0-9." >&2;
	else
		ret=0
	fi
	return ${ret}
}

# Default values for options
device=""
priority=""
title=""

# Option parsing
optstring="d:D:p:t:T:s:u:U:a:h"
while getopts ${optstring} c; do
    case ${c} in
        d) device="${OPTARG}" ;;
        D) timestamp="${OPTARG}" ;;
        p) priority="${OPTARG}" ;;
        t) title="${OPTARG}" ;;
        T) TOKEN="${OPTARG}" ;;
        s) sound="${OPTARG}" ;;
        u) url="${OPTARG}" ;;
        U) USER="${OPTARG}" ;;
        a) url_title="${OPTARG}" ;;
        
        [h\?]) usage ;;
    esac
done
shift $((OPTIND-1))

# Is there anything left?
if [ "$#" -lt 1 ]; then
    usage
fi
message="$*"

# Check for required config variables
if [ ! -x "${CURL}" ]; then
    echo "CURL is unset, empty, or does not point to curl executable. This script requires curl!" >&2
    exit 1
fi
validate_user_token "TOKEN" "${TOKEN}" "-T" || exit $?
validate_user_token "USER" "${USER}" "-U" || exit $?

curl_cmd="\"${CURL}\" -s \
    -F \"token=${TOKEN}\" \
    -F \"user=${USER}\" \
    -F \"message=${message}\" \
    $(opt_field device "${device}") \
    $(opt_field timestamp "${timestamp}") \
    $(opt_field priority "${priority}") \
    $(opt_field title "${title}") \
    $(opt_field sound "${sound}") \
    $(opt_field url "${url}") \
    $(opt_field url_title "${url_title}") \
    ${PUSHOVER_URL} 2>&1 >/dev/null || echo \"$0: Failed to send message\" >&2"
eval "${curl_cmd}"
