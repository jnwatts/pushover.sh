#!/bin/bash

# Default config vars
CURL="$(which curl)"
PUSHOVER_URL="https://api.pushover.net/1/messages.json"
TOKEN="" # May be set in pushover.conf or given on command line
user="" # May be set in pushover.conf or given on command line

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
    echo " -T <token>"
    echo " -s <sound>"
    echo " -u <url>"
    echo " -U <user>"
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
        T) token="${OPTARG}" ;;
        s) sound="${OPTARG}" ;;
        u) url="${OPTARG}" ;;
        U) user="${OPTARG}" ;;
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
if [ -z "${token}" ]; then
    echo "token is unset or empty: create ${CONFIG_FILE} or use -T" >&2
    exit 1
fi
if [ -z "${user}" ]; then
    echo "user is unset or empty: create ${CONFIG_FILE} or use -U" >&2
    exit 1
fi

curl_cmd="\"${CURL}\" -s \
    -F \"token=${token}\" \
    -F \"user=${user}\" \
    -F \"message=${message}\" \
    $(opt_field device "${device}") \
    $(opt_field timestamp "${timestamp}") \
    $(opt_field priority "${priority}") \
    $(opt_field title "${title}") \
    $(opt_field sound "${sound}") \
    $(opt_field url "${url}") \
    $(opt_field user "${user}") \
    $(opt_field url_title "${url_title}")  
    ${PUSHOVER_URL} 2>&1 >/dev/null || echo \"$0: Failed to send message\" >&2"
eval ${curl_cmd}
