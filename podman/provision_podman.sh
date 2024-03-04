#!/bin/bash

CONTAINER=$1
PROJECT=$2
DATABASE=$3
USER=$4
PASSWORD=$5

podman volume create $CONTAINER

podman run -d --name $CONTAINER -e POSTGRESQL_USER=$USER -e POSTGRESQL_PASSWORD=$PASSWORD -e POSTGRESQL_DATABASE=$DATABASE -p 5432:5432 -v postgres:/var/lib/pgsql/data registry.redhat.io/rhel8/postgresql-10

podman exec -ti $CONTAINER /usr/bin/psql postgres -c "ALTER user $USER REPLICATION;" && \
podman exec -ti $CONTAINER /usr/bin/psql $USER -c "CREATE PUBLICATION dbz_publication FOR ALL TABLES;" && \
podman exec -ti $CONTAINER /bin/bash -c "sed -i 's/\#wal_level \= replica/wal_level \= logical/g' /var/lib/pgsql/data/userdata/postgresql.conf" && \
podman exec -ti $CONTAINER /bin/bash -c "sed -i 's/\#max_wal_senders \= 10/max_wal_senders \= 4/g' /var/lib/pgsql/data/userdata/postgresql.conf" && \
podman exec -ti $CONTAINER /bin/bash -c "sed -i 's/\#smax_replication_slots \= 10/max_replication_slots \= 4/g' /var/lib/pgsql/data/userdata/postgresql.conf" && \
podman restart $CONTAINER