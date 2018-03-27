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

# Fixed global parameters
EXCLUDE_NAMESPACES="default|kube-public|weave|kube-system"
EXCLUDE_OBJECTS="default-token"
# When restoring, the object types will be restored by this specific order (if backed-up)
INCLUDE_OBJECT_TYPES="secrets|configmaps|deployments|hpa|services|ingresses"

. $BASEDIR/modules/utils.sh
. $BASEDIR/modules/prerequisites.sh
if [ "$RESTORE" == "true" ]; then
    . $BASEDIR/modules/restore.sh
fi
if [ "$BACKUP" == "true" ]; then
    . $BASEDIR/modules/backup.sh
fi
