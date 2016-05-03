#!/bin/bash

# Configuration values
ICINGA_URL="ICINGA URL"
SLACK_WEBHOOK_URL="SLACK URL"

#Set the message icon based on ICINGA service state
case $SERVICESTATE in
	CRITICAL)
		_ICON=':bomb:'
		_COLOR='danger'
		;;
	WARNING)
		_ICON=':warning:'
		_COLOR='warning'
		;;
	OK)
		_ICON=':beer:'
		_COLOR='good'
		;;
	UNKNOWN)
		_ICON=':question:'
		;;
	*)
		_ICON=':white_medium_square:'
		;;
esac

# Helping variables
_HOSTNAME='<'${ICINGA_URL}'/icingaweb2/monitoring/host/services?host='${HOSTNAME}'|'${HOSTDISPLAYNAME}'>'
_SERVICE='<'${ICINGA_URL}'/icingaweb2/monitoring/service/show?host='${HOSTNAME}'&service='${SERVICEDESC}'|'${SERVICEDISPLAYNAME}'>'
_DASH_SERVICE=${ICINGA_URL}'/icingaweb2/dashboard#!/icingaweb2/monitoring/service/show?host='${HOSTNAME}'&service='${SERVICEDESC}

# Build the payload
PAYLOAD=$(cat << ENDJSON
{
    "icon_emoji": "$_ICON",
    "text": ":mega: New notification from icinga2",
    "attachments": [
        {
            "title": "$SERVICEOUTPUT",
            "title_link": "$_DASH_SERVICE",
            "color": "$_COLOR",
            "author_name": "icinga2",
            "author_link": "http://www.icinga.org",
            "author_icon": "https://wiki.icinga.org/download/attachments/131074/global.logo",
            "fields": [
                {
                    "title": "HOST",
                    "value": "$_HOSTNAME",
                    "short": true
                },
                {
                    "title": "SERVICE",
                    "value": "$_SERVICE",
                    "short": true
                }
            ]
        }
    ]
}
ENDJSON
)

#Send message to Slack
curl --connect-timeout 30 --max-time 60 -sS -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$SLACK_WEBHOOK_URL"
