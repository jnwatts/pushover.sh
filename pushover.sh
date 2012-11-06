#!/bin/bash

# Default config vars
CURL="$(which curl)"
PUSHOVER_URL="https://api.pushover.net/1/messages"
TOKEN="" # Must be set in pushover.conf
USER="" # Must be set in pushover.conf

# Load user config
CONFIG_FILE="${XDG_CONFIG_HOME-${HOME}/.config}/pushover.conf"
. ${CONFIG_FILE}

# Check for required config variables
if [ ! -x "${CURL}" ]; then
    echo "CURL is unset, empty, or does not point to curl executable. This script requires curl!" >&2
    exit 1
fi
if [ -z "${TOKEN}" ]; then
    echo "TOKEN is unset or empty: Did you create ${CONFIG_FILE}?" >&2
    exit 1
fi
if [ -z "${USER}" ]; then
    echo "USER is unset or empty: Did you create ${CONFIG_FILE}?" >&2
    exit 1
fi

# Functions used elsewhere in this script
usage() {
    echo "${0} [-t <title>] [-d <device>] <message>"
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

# Default values for options
device=""
title=""

# Option parsing
optstring="d:t:h"
while getopts ${optstring} c; do
    case ${c} in
        d) device="${OPTARG}" ;;
        t) title="${OPTARG}" ;;
        [h\?]) usage ;;
    esac
done
shift $((OPTIND-1))

# Is there anything left?
if [ "$#" -lt 1 ]; then
    usage
fi
message="$*"

curl_cmd="\"${CURL}\" -s \
   -F \"token=${TOKEN}\" \
   -F \"user=${USER}\" \
   -F \"message=${message}\" \
   $(opt_field title "${title}") \
   $(opt_field device "${device}") \
   ${PUSHOVER_URL} 2>&1 >/dev/null || echo \"$0: Failed to send message\" >&2"
eval "${curl_cmd}" 
