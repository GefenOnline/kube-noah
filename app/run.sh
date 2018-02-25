#!/bin/bash

# Set Global parameters with injected environment variables or their default value
BASEDIR=$(dirname "$0")
INTERVAL="${INTERVAL:-5m}"
GIT_DIR="${GIT_DIR:-/tmp/certificates}"
GIT_USER_NAME="${GIT_USER_NAME:-tlser service}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-tlser@service.com}"
ENVIRONMENT=$ENVIRONMENT
RESTORE=$RESTORE
BACKUP=$BACKUP

# Fixed Global parameters
EXCLUDE_NAMESPACES="default|kube-public|weave|kube-system"
EXCLUDE_OBJECTS="default-token"
INCLUDE_OBJECT_TYPES="deployments|secrets"


. $BASEDIR/modules/utils.sh
#. $BASEDIR/modules/prerequisites.sh
[ "$RESTORE" == "true" ] && . $BASEDIR/modules/restore.sh
[ "$BACKUP" == "true" ]  && . $BASEDIR/modules/backup.sh || exit 0
