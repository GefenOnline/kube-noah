#!/bin/bash

# Set Global parameters with injected environment variables or their default value
BASEDIR=$(dirname "$0")
GIT_LOCAL_DIR="${GIT_LOCAL_DIR:-/tmp/kube-ark}"
GIT_USER_NAME="${GIT_USER_NAME:-kube-noah service}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-kube-noah@service.com}"
GIT_REPO_URL=$GIT_REPO_URL
KUBE_CLUSTER_NAME=$KUBE_CLUSTER_NAME
RESTORE=$RESTORE
BACKUP=$BACKUP

# Fixed Global parameters
EXCLUDE_NAMESPACES="default|kube-public|weave|kube-system|yellow|green"
EXCLUDE_OBJECTS="default-token"
INCLUDE_OBJECT_TYPES="deployments|hpa|secrets|configmaps|ingresses|services"

. $BASEDIR/modules/utils.sh
. $BASEDIR/modules/prerequisites.sh
[ "$RESTORE" == "true" ] && . $BASEDIR/modules/restore.sh
[ "$BACKUP" == "true" ]  && . $BASEDIR/modules/backup.sh
