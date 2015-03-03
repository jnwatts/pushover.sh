#!/bin/bash

# Default config vars
CURL="$(which curl)"
PUSHOVER_URL="https://api.pushover.net/1/messages.json"
TOKEN="" # May be set in pushover.conf or given on command line
USER="" # May be set in pushover.conf or given on command line
proxconf=""

# Load user config
if [ ! -z "${PUSHOVER_CONFIG}" ]; then
    CONFIG_FILE="${PUSHOVER_CONFIG}"
else
    CONFIG_FILE="${XDG_CONFIG_HOME-${HOME}/.config}/pushover.conf"
fi
if [ -e "${CONFIG_FILE}" ]; then
    . "${CONFIG_FILE}"
fi

# Functions used elsewhere in this script
usage() {
    echo "${0} <options> <message>"
    echo " -c <callback>"
    echo " -d <device>"
    echo " -D <timestamp>"
    echo " -e <expire>"
    echo " -p <priority>"
    echo " -r <retry>"
    echo " -t <title>"
    echo " -T <TOKEN> (required if not in config file)"
    echo " -s <sound>"
    echo " -u <url>"
    echo " -U <USER> (required if not in config file)"
    echo " -a <url_title>"
	echo " -P <http://proxy:port/>"
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

# Option parsing
optstring="c:d:D:e:p:r:t:T:s:u:U:a:P:h"
while getopts ${optstring} c; do
    case ${c} in
        c) callback="${OPTARG}" ;;
        d) device="${OPTARG}" ;;
        D) timestamp="${OPTARG}" ;;
        e) expire="${OPTARG}" ;;
        p) priority="${OPTARG}" ;;
        r) retry="${OPTARG}" ;;
        t) title="${OPTARG}" ;;
        T) TOKEN="${OPTARG}" ;;
        s) sound="${OPTARG}" ;;
        u) url="${OPTARG}" ;;
        U) USER="${OPTARG}" ;;
        a) url_title="${OPTARG}" ;;
		P) proxconf="${OPTARG}" ;;

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
else
	if ! [ -z "$proxconf" ]
	then
		tpconf="$proxconf"

		proxconf="$(echo $proxconf | cut -f 3 -d\/)"
		proxconf="$(echo $proxconf | cut -f 1 -d\:)"

		chkProxy=$(ping -c 1 $proxconf)

		if [[ "$chkProxy" == *"ping: unknown host"* ]]
		then
			proxconf=""	
		else
			proxconf="--proxy $tpconf"	
		fi
	fi
fi
validate_user_token "TOKEN" "${TOKEN}" "-T" || exit $?
validate_user_token "USER" "${USER}" "-U" || exit $?

curl_cmd="\"${CURL}\" $proxconf -s \
    -F \"token=${TOKEN}\" \
    -F \"user=${USER}\" \
    -F \"message=${message}\" \
    $(opt_field callback "${callback}") \
    $(opt_field device "${device}") \
    $(opt_field timestamp "${timestamp}") \
    $(opt_field priority "${priority}") \
    $(opt_field retry "${retry}") \
    $(opt_field expire "${expire}") \
    $(opt_field title "${title}") \
    $(opt_field sound "${sound}") \
    $(opt_field url "${url}") \
    $(opt_field url_title "${url_title}") \
    \"${PUSHOVER_URL}\" 2>&1 >/dev/null"

# execute and return exit code from curl command
eval "${curl_cmd}" && exit 0 || r=$?
echo "$0: Failed to send message" >&2
exit $r
