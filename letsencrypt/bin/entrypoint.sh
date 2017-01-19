#!/bin/bash

set -e

# Validate required environment variables.
[[ -z "$DOMAINS" ]] && MISSING="$MISSING DOMAINS"
[[ -z "$EMAIL" ]] && MISSING="$MISSING EMAIL"
[[ -z "$LOAD_BALANCER_SERVICE_NAME" ]] && MISSING="$MISSING LOAD_BALANCER_SERVICE_NAME"

if [[ -n "$MISSING" ]]; then
  echo "Missing required environment variables: $MISSING" >&2
  exit 1
fi

# Create a web server right away, otherwise HAProxy might not see that
# the server is listening and you won't be able to authenticate
echo "Creating http server port 80"
mkdir -p /opt/www
(pushd /opt/www && python -m SimpleHTTPServer 80) &

# Wait for the local server to be listening
while ! nc -z localhost 80;
do
  echo "SimpleHTTPServer not up yet, waiting 1 second";
  sleep 1;
done

echo "waiting for service \"${LOAD_BALANCER_SERVICE_NAME}\""

# Wait for HAproxy to start before updating certificates on startup.
while ! nc -z $LOAD_BALANCER_SERVICE_NAME 80;
do
  echo "Loadbalancer service \"${LOAD_BALANCER_SERVICE_NAME}\" is not up yet, waiting 5 second";
  sleep 5;
done

echo "Loadbalancer service \"${LOAD_BALANCER_SERVICE_NAME}\" is online, updating certificates..."
(update-certs.sh) &

exec "$@"
