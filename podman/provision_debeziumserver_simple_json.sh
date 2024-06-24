#!/bin/bash

podman volume create debezium_conf
if [ $? != 0 ]; then
  echo "volume debezium_conf already existent"
  exit
fi


cat <<EOF > /home/gmagnott/.local/share/containers/storage/volumes/debezium_conf/_data/application.properties
debezium.sink.type=http
debezium.sink.http.url=http://dumper:8080
debezium.source.connector.class=io.debezium.connector.postgresql.PostgresConnector
debezium.source.offset.storage.file.filename=data/offsets.dat
debezium.source.offset.flush.interval.ms=0
debezium.source.database.hostname=postgresql
debezium.source.database.port=5432
debezium.source.database.user=postgresql
debezium.source.database.password=postgresql
debezium.source.database.dbname=postgresql
debezium.source.database.server.name=tutorial
debezium.source.schema.whitelist=Battalion,Member,equipment
debezium.source.plugin.name=pgoutput
debezium.source.topic.prefix=sample_prefix
debezium.transforms=unwrap
debezium.transforms.unwrap.type=io.debezium.transforms.ExtractNewRecordState
debezium.transforms.unwrap.drop.tombstones=false
debezium.transforms.unwrap.add.headers=op
debezium.format.value=json
debezium.format.value.schemas.enable=false
debezium.format.key=json
debezium.format.key.schemas.enable=false
debezium.format.header=json
debezium.format.header.schemas.enable=false
quarkus.log.console.json=false
EOF


podman volume create debezium_data
if [ $? != 0 ]; then
  echo "volume debezium_data already existent"
  exit
fi

podman run --name debezium --net dev -p 8080:8080 -v debezium_conf:/debezium/conf -v debezium_data:/debezium/data debezium/server

