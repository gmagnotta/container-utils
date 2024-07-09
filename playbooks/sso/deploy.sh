#!/bin/sh

export CONTAINER_UTILS="/home/gmagnott/src/container-utils"
export CWD=`pwd`

export PROJECT="sso"
#export REGISTRY_USERNAME="user"
#export REGISTRY_PASSWORD="password"
export POSTGRESQL_DATABASE="sso"
export POSTGRESQL_USER="sso"
export POSTGRESQL_PASSWORD="sso"
export SSO_HOSTNAME="sso.apps.cluster-gwjxk.dynamic.redhatworkshops.io"

set -e

ansible-playbook -e project=$PROJECT -e registry_username=$REGISTRY_USERNAME \
 -e registry_password=$REGISTRY_PASSWORD \
 $CONTAINER_UTILS/playbooks/playbook_initialize_project.yaml

ansible-playbook -e project=$PROJECT \
 -e postgresql_database=$POSTGRESQL_DATABASE \
 -e postgresql_user=$POSTGRESQL_USER \
 -e postgresql_password=$POSTGRESQL_PASSWORD \
 $CONTAINER_UTILS/playbooks/postgresql/playbook_provision_postgresql.yaml

ansible-playbook -e project=$PROJECT \
 -e hostname=$SSO_HOSTNAME \
 -e database_username=$POSTGRESQL_USER \
 -e database_name=$POSTGRESQL_DATABASE \
 -e database_password=$POSTGRESQL_PASSWORD \
 $CONTAINER_UTILS/playbooks/sso/playbook_provision_sso.yaml
