#!/bin/sh
set -e

PASTE_DIR="/var/www/pastes"
DOMAIN="localhost" # Change this to your domain or container IP
HEX_NAME=$(head -c 4 /dev/urandom | xxd -p) # Generates an 8-character random string

cat > "${PASTE_DIR}/${HEX_NAME}"

chmod 644 "${PASTE_DIR}/${HEX_NAME}"

echo "https://${DOMAIN}/${HEX_NAME}"
