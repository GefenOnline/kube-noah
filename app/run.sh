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

# When backing up, only these object types will be backed up
# When restoring, only these object types will be restored and in that specific order
INCLUDE_OBJECT_TYPES="secrets|configmaps|deployments|hpa|services|ingresses"
# When backing up, only the INCLUDE_OBJECT_TYPES that tolerate this filter will be backed up (using kubectl --show-labels)
OBJECTS_FILTER="backed-up-by=kube-noah|kubernetes.io/tls"

. $BASEDIR/modules/utils.sh
. $BASEDIR/modules/prerequisites.sh
if [ "$RESTORE" == "true" ]; then
    . $BASEDIR/modules/restore.sh
fi
if [ "$BACKUP" == "true" ]; then
    . $BASEDIR/modules/backup.sh
fi
