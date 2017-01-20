# How to use it

```
version: "2"
services:
  haproxy:
    image: m21lab/haproxy:1.6.2
    links:
      - letsencrypt
      - web ## THIS IS THE SERVICE HOSTED BEHIND THE NEW CERTIFICATE
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    volumes_from:
      - letsencrypt
  letsencrypt:
    image: m21lab/letsencrypt:1.0
    environment:
      - DOMAINS=YOUR_DOMAIN
      - EMAIL=admins@YOUR_DOMAIN
      - LOAD_BALANCER_SERVICE_NAME=haproxy
      # THIS IS CRUCIAL WHEN TESTING to avoid reaching
      # the 5 certificates limit per domain per week. 
      # You'll end up waiting a week before being able 
      # to regenerate a valid cert if you don't backup
      # the once generated
      - OPTIONS=--staging

  web:
    environment:
      - FORCE_SSL=yes
      - VIRTUAL_HOST=http://*,https://*
    image: dockercloud/hello-world:latest
```
# Overview

The `haproxy` image will:

  * Create a self signed default certificate, so HAproxy can start before we
    have any real certificates.

  * Watch the `/etc/letsencrypt/live` directory and when changes are detected,
  	install combined certificates and reload HAproxy.

The `letsencrypt` image will:

  * Automatically create or renew certificates on startup and daily thereafter.

# Usage

In your stack file:

  * Link to the `letsencrypt` service from the `haproxy` service.

  * Use `volumes_from: letsencrypt` in the `haproxy` service.

  * Define a `DOMAINS` environment variable in the `letsencrypt` service.
    Certificates are separated by semi-colon (;) and domains are separated by
    comma (,).

  * Define an `EMAIL` environment variable in the `letsencrypt` service. It
    will be used for all certificates.

  * Define an `OPTIONS` environment variable in the `letsencrypt` service, if
    you want to pass additional arguments to `certbot` (e.g. `--staging`).

    ***VERY IMPORTANT***

    Make sure you set the environment variable OPTIONS: --staging on the letsencrypt
    service  until you are 100% sure you are configured properly and you want to get
    a real certificate. Otherwise you’ll reache the 5 certificates limit per domain
    per week and you’ll end up waiting a week before being able to regenerate a valid
    certificate if you didn’t backup the ones already generated

  * Define an `LOAD_BALANCER_SERVICE_NAME` environment variable in the
    `letsencrypt` service. It is used to wait for this service to be listening
    on port 80 before starting the `letsencrypt` service.

Several environment variables are hard coded, and don't need to be defined in
your stack file:

  * The `DEFAULT_SSL_CERT` environment variable is set to the value of the
  	default/first Let's Encrypt certificate (if not already explicitly set),
  	to ensure SSL termination is enabled.

  * The `VIRTUAL_HOST` and `VIRTUAL_HOST_WEIGHT` environment variables are hard
    coded in the `letsencrypt` image, to ensure challenge requests for all
    domains are proxied to the `letsencrypt` service.

A sample stack file is provided.
