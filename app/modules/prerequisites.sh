#!/bin/bash
# -------------
# Prerequisites 
# -------------

function prerequisites {

    # Checking for environment variables
    if [ -z "$GIT_REPO_URL" ]; then
        echo $(logPrefix) - Error : Environment variable \"GIT_REPO_URL\" must be set
        exit 1
    fi
    if [ -z "$KUBE_CLUSTER_NAME" ]; then
        echo $(logPrefix) - Error : Environment variable \"KUBE_CLUSTER_NAME\" must be set
        exit 1
    fi
    if [ "$RESTORE" != "true" ] && [ "$BACKUP" != "true" ]; then 
        echo $(logPrefix) - Error : At least one of the environment variables \"RESTORE\" or \"BACKUP\" must be set to true
        exit 1
    fi

    # Printing Environment variables
    echo $(logPrefix) - Working under Kubernetes cluster : $KUBE_CLUSTER_NAME
    [ "$RESTORE" == "true" ] && echo $(logPrefix) - Will execute RESTORE
    [ "$BACKUP" == "true" ]  && echo $(logPrefix) - Will execute BACKUP

    # Cloning Kubernetes objects storage Git Repository and configure Git user name and user email or exit
    echo $(logPrefix) - Cloning Git repository
    git clone $GIT_REPO_URL $GIT_DIR || exit
    echo $(logPrefix) - Configuring git user.name  : $GIT_USER_NAME
    git config --global user.name $GIT_USER_NAME || exit
    echo $(logPrefix) - Configuring git user.email : $GIT_USER_EMAIL
    git config --global user.email $GIT_USER_EMAIL || exit

}

# Main
echo $(logPrefix) "-------------"
echo $(logPrefix) "Prerequisites"
echo $(logPrefix) "-------------"
prerequisites


