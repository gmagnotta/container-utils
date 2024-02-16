#!/bin/sh

podman network create --ignore dev

podman run -d --rm --name ssodb --net dev \
 -e POSTGRESQL_USER="sso" \
 -e POSTGRESQL_PASSWORD="sso" \
 -e POSTGRESQL_DATABASE="sso" \
 registry.redhat.io/rhel8/postgresql-10:1-232

sleep 15

if [ ! -f ssokeystore.jks ]; then
  echo "Generate Secrets"
  keytool -genkeypair -storepass password -dname "CN=keycloak" -alias server -storetype PKCS12 -keyalg RSA -keysize 2048 -keystore sso.keystore
fi

podman run -d --rm --name keycloak --net dev \
 -v ./sso.keystore:/opt/certs/sso.keystore:z \
 -e KC_HOSTNAME="keycloak:8081" \
 -e KC_HTTP_PORT="8081" \
 -e KC_HTTPS_PORT="8444" \
 -e KC_DB="postgres" \
 -e KC_DB_USERNAME="sso" \
 -e KC_DB_PASSWORD="sso" \
 -e KC_DB_URL_DATABASE="sso" \
 -e KC_DB_URL_HOST="ssodb" \
 -e KC_HEALTH_ENABLED="true" \
 -e KC_PROXY="passthrough" \
 -e KEYCLOAK_ADMIN="admin" \
 -e KEYCLOAK_ADMIN_PASSWORD="password" \
 -e KC_HTTPS_KEY_STORE_FILE="/opt/certs/sso.keystore" \
 -e KC_HTTPS_KEY_STORE_PASSWORD="password" \
 -p 8081:8081 \
 -p 8444:8444 \
 registry.redhat.io/rhbk/keycloak-rhel9@sha256:d18adf0219a17b6619ddfb86a7d569019481f0315d94917793038ba5c6dc9567 start-dev

#KC_HTTPS_CERTIFICATE_FILE: /mnt/certificates/tls.crt
#KC_HTTPS_CERTIFICATE_KEY_FILE: /mnt/certificates/tls.key
#KC_CACHE: ispn
#KC_CACHE_STACK: kubernetes
