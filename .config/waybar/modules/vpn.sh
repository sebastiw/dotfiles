#!/bin/sh

TO_JSON='function remove_whitespace(str) { return gensub(/[[:space:]]/, "", "g", str); } BEGIN { json="{"; } /^[[:space:]]*$/ { next; } /^Tips/ { exit 0; } conn { json=json"\"Server\": \""remove_whitespace($1)"\","; conn=0; next; } /^VPN/ && !/DISCONNECTED/ { conn=1; } { json=json"\""remove_whitespace($1)"\": \""remove_whitespace($2)"\"," } END { print substr(json, 1, length(json)-1)"}"; }'

VPN_STATUS=$(ivpn status | awk -F":" -e "$TO_JSON")

STATUS="$(echo "$VPN_STATUS" | jq -r '.VPN')"

if [[ "$STATUS" == "CONNECTED" ]]
then
    SERVER="$(echo "$VPN_STATUS" | jq -r '.Server')"
    echo -e "{\"text\":\"￢\", \"alt\": \"$STATUS\", \"tooltip\":\"$SERVER\"}"
else
    echo -e "{\"text\":\"＠\", \"alt\": \"$STATUS\", \"tooltip\": \"$STATUS\"}"
fi
