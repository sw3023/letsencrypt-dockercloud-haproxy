#!/bin/bash

set -e

install-certs.sh
watch-certs.sh &

# Use the default created self signed SSL certificate until
# we receive letsencrypt certificates
LETSENCRYPT_CERT="$(cat /certs/temp-cert.pem)"
export DEFAULT_SSL_CERT="${DEFAULT_SSL_CERT:-$LETSENCRYPT_CERT}"

exec "$@"
