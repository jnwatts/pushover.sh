#!/bin/bash

# Default config vars
CURL="$(which curl)"
PUSHOVER_URL="https://api.pushover.net/1/messages"
TOKEN="" # Must be set in pushover.conf or given on command line
USER=""  # Must be set in pushover.conf

# Load user config
[[ -n $XDG_CONFIG_HOME ]] || XDG_CONFIG_HOME=$HOME/.config
CONFIG_FILE="${XDG_CONFIG_HOME-${HOME}/.config}/pushover.conf"
if [[ -e "${CONFIG_FILE}" ]]; then
    . ${CONFIG_FILE}
else
    echo -e 'TOKEN="" #your application token\nUSER="" #your user key' > $CONFIG_FILE
    echo "Please edit ${CONFIG_FILE}: User Key or Token not set." >&2
    exit 1
fi

# Functions used elsewhere in this script
usage() {
    echo "$1 <options> <message>"
    echo " -d <device>"
    echo " -p <priority>"
    echo " -t <title>"
    echo " -T <token>" 
}

opt_field() {
    field=$1
    shift
    value="${*}"
    if [[ -n "${value}" ]]; then
        echo "-F \"${field}=${value}\""
    fi
}

# Default values for options
device=""
priority=""
title=""

# Option parsing
while getopts "d:p:t:T:h" c; do
    case ${c} in
        d) device="${OPTARG}" ;;
        p) priority="${OPTARG}" ;;
        t) title="${OPTARG}" ;;
        T) TOKEN="${OPTARG}" ;;
        [h\?]) usage $(basename $0); exit 0; ;;
    esac
done
shift $((OPTIND-1))

# Is there anything left?
if [[ "$#" -lt 1 ]]; then
    usage $(basename $0)
    exit 1
fi
message="$*"

# Check for required config variables
if [[ ! -x "${CURL}" ]]; then
    echo "CURL is unset, empty, or does not point to curl executable. This script requires curl!" >&2
    exit 1
fi
if [[ -z "${TOKEN}" ]]; then
    echo "TOKEN is unset or empty: Did you create ${CONFIG_FILE}?" >&2
    exit 1
fi
if [[ -z "${USER}" ]]; then
    echo "USER is unset or empty: Did you create ${CONFIG_FILE}?" >&2
    exit 1
fi

curl_cmd="\"${CURL}\" -s \
    -F \"token=${TOKEN}\" \
    -F \"user=${USER}\" \
    -F \"message=${message}\" \
    $(opt_field title "${title}") \
    $(opt_field device "${device}") \
    $(opt_field priority "${priority}") \
    ${PUSHOVER_URL} 2>&1 >/dev/null" 
eval "${curl_cmd}" || echo "$(basename $0): Failed to send message" >&2 

