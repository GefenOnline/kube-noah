#!/bin/bash
# ----------------------------------------------
# Restore Kubernetes objects from Git repository
# ----------------------------------------------

# Push Kubernetes objects to kubernetes cluster
function pushToKube {
    
    # Checking if Kubernetes cluster directory doesn't exist, if so exiting gracefully
    if [ ! -d "$GIT_LOCAL_DIR/$KUBE_CLUSTER_NAME" ]; then

        echo $(logPrefix) - No Kubernetes cluster directory by the name $GIT_DIR/$KUBE_CLUSTER_NAME found.
        echo $(logPrefix) - Nothing to do...

    else
        # Iterate over namespace directories
        for nameSpaceDir in $GIT_LOCAL_DIR/$KUBE_CLUSTER_NAME/*; do

            # Getting namespace name from namespace directory and applying yaml to kubernetes cluster
            nameSpace=$(basename $nameSpaceDir);
            echo $(logPrefix) - Applying namespace: \'$nameSpace\' from file: $nameSpaceDir/$nameSpace.yml
            kubectl apply -f $nameSpaceDir/$nameSpace.yml || exit

            for objectTypeDir in $GIT_LOCAL_DIR/$KUBE_CLUSTER_NAME/$nameSpace/*; do

                # Filter directories under namespace directory
                if [ -d $objectTypeDir ]; then
                    # Getting object type name from object type directory and applying yaml to kubernetes cluster
                    objectType=$(basename $objectTypeDir);
                    echo $(logPrefix) - Applying objects of type: \'$objectType\' for namespace: \'$nameSpace\' from directory: $objectTypeDir
                    kubectl apply --namespace=$nameSpace -f $objectTypeDir || exit
                fi

            done

        done

    fi
}

# Main
echo $(logPrefix) "----------------------------------------------"
echo $(logPrefix) "Restore Kubernetes objects from Git repository"
echo $(logPrefix) "----------------------------------------------"
pushToKube
echo $(logPrefix) "------------------------------------------------------------"
echo $(logPrefix) "Successfully restored Kubernetes objects from Git repository"
echo $(logPrefix) "------------------------------------------------------------"
