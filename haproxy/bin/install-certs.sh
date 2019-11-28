#!/bin/bash

set -e

mkdir -p /certs
mkdir -p "$LIVE_CERT_FOLDER"

# Create a self signed default certificate, so HAproxy can start before we have
# any real certificates.
if [[ ! -f /certs/temp-cert.pem ]]; then
	openssl req -x509 -newkey rsa:2048 -keyout key.pem -out ca.pem -days 90 -nodes -subj '/CN=*/O=Temp SSL Cert/C=US'
	cat key.pem ca.pem > /certs/temp-cert.pem
	rm key.pem ca.pem
fi


# Install combined certificates for HAproxy.
if [[ -n "$(ls -A $LIVE_CERT_FOLDER)" ]]; then
	COUNT=0
	for DIR in "$LIVE_CERT_FOLDER"/*; do
	    if [ "foo" = "foo" ]; then
		cat "$DIR/privkey.pem" "$DIR/fullchain.pem" > /certs/letsencrypt$COUNT.pem
		(( COUNT += 1 ))
	    fi
	done
fi
