#!/bin/bash

# Parse CLI arg[0] for user@ip or else use default
USER=${1%@*}
if [ "$USER" == "$1" ]; then
    USER="ubuntu" # edit default username as necessary or pass in via CLI
fi

IP_ADDR=${1##*@}

# Validate IPv4 address
if ! [[ "$IP_ADDR" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || [[ "${IP_ADDR}" == 127.0.0.1 ]]; then
    echo "Error: Invalid IP address. Please provide a valid IPv4 address."
    exit 1
fi

IFS='.' read -r i1 i2 i3 i4 <<< "$IP_ADDR"
if [ "$i1" -gt 255 ] || [ "$i2" -gt 255 ] || [ "$i3" -gt 255 ] || [ "$i4" -gt 255 ]; then
    echo "Error: Invalid IP address. Each octet must be between 0 and 255."
    exit 1
fi

# .pem key priority:
#   1: CLI optional second argument
#   2: First found in current directory
#   3: default value (optional -d flag to force use default)
PEM_KEY="./<KEY_PATH>/<KEY_NAME>.pem"
if [ -n "$2" ]; then
    if [ "$2" != "-d" ]; then
        PEM_KEY="$2"
    fi
elif [ -n "$(ls *.pem 2>/dev/null)" ]; then
    PEM_KEY=$(ls *.pem | head -n 1)
    echo "Using: $PEM_KEY found in current directory"
else
    echo "Using default: $PEM_KEY"
fi

if [ ! -f "$PEM_KEY" ]; then
    echo "Error: PEM key file not found at $PEM_KEY"
    exit 1
fi

# detect and fix .pem permissions if necessary
CURRENT_PERMISSIONS=$(stat -c "%a" "$PEM_KEY")

if [ "$CURRENT_PERMISSIONS" != "400" ]; then
    chmod 400 "$PEM_KEY"
fi

ssh -i "$PEM_KEY" "$USER@$IP_ADDR"