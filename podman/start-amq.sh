#!/bin/sh

podman network create --ignore dev

podman run -d --rm --name amqbroker --net dev \
 -e AMQ_USER="amq" \
 -e AMQ_PASSWORD="amq" \
 -e AMQ_ROLE="admin" \
 -e AMQ_TRANSPORTS="openwire" \
 -e AMQ_QUEUES="" \
 -e AMQ_ADDRESSES="" \
 -e MQ_SERIALIZABLE_PACKAGES="" \
 -e AMQ_SPLIT="false" \
 -e AMQ_MESH_DISCOVERY_TYPE="dns" \
 -e AMQ_MESH_SERVICE_NAME="" \
 -e AMQ_MESH_SERVICE_NAMESPACE="" \
 -e AMQ_STORAGE_USAGE_LIMIT="1 gb" \
 -e KEYCLOAK_ADMIN_PASSWORD="password" \
 -p 8161:8161 \
 registry.redhat.io/amq7/amq-broker-rhel8:7.8
