#!/bin/bash

podman volume create debezium_conf
if [ $? != 0 ]; then
  echo "volume debezium_conf already existent"
  exit
fi


cat <<EOF > /home/gmagnott/.local/share/containers/storage/volumes/debezium_conf/_data/application.properties
debezium.sink.type=http
debezium.sink.http.url=http://commander-cache:8080
debezium.source.connector.class=io.debezium.connector.postgresql.PostgresConnector
debezium.source.offset.storage.file.filename=data/offsets.dat
debezium.source.offset.flush.interval.ms=0
debezium.source.database.hostname=postgresql
debezium.source.database.port=5432
debezium.source.database.user=postgresql
debezium.source.database.password=postgresql
debezium.source.database.dbname=postgresql
debezium.source.database.server.name=tutorial
debezium.source.schema.whitelist=Battalion,Member,Equipment
debezium.source.plugin.name=pgoutput
debezium.source.topic.prefix=sample_prefix
debezium.format.value=cloudevents
debezium.format.key=json
debezium.format.key.schemas.enable=false
debezium.format.header=json
debezium.format.header.schemas.enable=false
quarkus.log.console.json=false
quarkus.http.port=8080
EOF


podman volume create debezium_data
if [ $? != 0 ]; then
  echo "volume debezium_data already existent"
  exit
fi

podman run --name debezium --net dev -v debezium_conf:/debezium/conf -v debezium_data:/debezium/data docker.io/debezium/server@sha256:9fdec631dc5ba3257151a05d0aabc0c6dd2a2f10a0e54d37de9b9bb40dd76a25

