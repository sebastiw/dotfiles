#!/bin/sh

VPN="/opt/linux@cisco/cisco-secure-client-linux64-5.0.03072/vpn/vpn"
CMD="stats"

TO_JSON='function remove_whitespace(str) { return gensub(/[[:space:]]/, "", "g", str); } BEGIN { json="{"; } /^[[:space:]]*$/ { next; } /^Tips/ { exit 0; } conn { json=json"\"Server\": \""remove_whitespace($1)"\","; conn=0; next; } /^VPN/ && !/DISCONNECTED/ { conn=1; } /:/ { FS=":"; json=json"\""remove_whitespace($1)"\": \""remove_whitespace($2)"\"," } END { print substr(json, 1, length(json)-1)"}"; }'

# $VPN -h 2>&1 >/dev/null
# if [ "$?" = "1" ]
if [ ! -x "$VPN" ]
then
    # link-variant-off
    echo '{"text":"󰌺", "alt": "VPN", "tooltip": "VPN not installed"}'
    exit 0
fi

# VPN_STATUS=$("$VPN" "$CMD" | awk -F":" "$TO_JSON")
VPN_STATUS='{"VPN": "Disconnected"}'
STATUS="$(echo "$VPN_STATUS" | jq -r '.VPN//.ConnectionState')"

case "$STATUS" in
    "CONNECTED"|"Connected")
        SERVER="$(echo "$VPN_STATUS" | jq -r '.Server//.ServerAddress')"
        # key-wireless
        echo '{"text":"󰿂", "alt": "'"$STATUS"'", "tooltip":"'"$SERVER"'"}'
        ;;
    *)
        # lasso
        echo '{"text":"󰼃", "alt": "'"$STATUS"'", "tooltip": "'"$STATUS"'"}'
esac
