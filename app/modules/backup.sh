#!/bin/bash
# -------------------------------------------
# Backup Kubernetes objects to Git repository
# -------------------------------------------

# Push to Git repository new changes if found
function pushToGit {

    # Collect Git status output
    statusOutput=$(git --git-dir=$GIT_LOCAL_DIR/.git --work-tree=$GIT_LOCAL_DIR status -s)

    # Checking for changes - add, commit, pull and push if necessary
    if [ ! -z "$statusOutput" ]; then

    	echo $(logPrefix) - New changes detected: $statusOutput
    	git --git-dir=$GIT_LOCAL_DIR/.git --work-tree=$GIT_LOCAL_DIR add -A
    	git --git-dir=$GIT_LOCAL_DIR/.git --work-tree=$GIT_LOCAL_DIR commit -am "Automatic changes by by tlser service"

    	# Pulling changes or exit if there is a merge conflict
        echo $(logPrefix) - Pulling changes from the Git repository
    	git --git-dir=$GIT_LOCAL_DIR/.git --work-tree=$GIT_LOCAL_DIR pull --no-edit || exit

	    # Pushing changes or exit if changes where still made someplace else between the last pull (which is the command above) to this push
    	git --git-dir=$GIT_LOCAL_DIR/.git --work-tree=$GIT_LOCAL_DIR push || exit
    	echo $(logPrefix) - New changes successfully pushed to the Git repository.

    else
        echo $(logPrefix) - No new changes were found.
    fi
}

# Exports Kubernetes objects as yaml files to the git folder
function pullFromKube {
    
    # Get list of filtered Kubernetes namespaces 
    nameSpaces=$(kubectl get namespaces --output custom-columns=NAME:.metadata.name | egrep -v "$EXCLUDE_NAMESPACES" | grep -v NAME);

    # If namespaces were found, iterate one by one
    [ ! -z "$nameSpaces" ] &&
    echo $(logPrefix) - Detected namespaces: \'$nameSpaces\' for backup... &&
    while read -r nameSpace; do

        # Creating folder for the namespace if absent
        nameSpaceDir=$GIT_LOCAL_DIR/$KUBE_CLUSTER_NAME/$nameSpace
        echo $(logPrefix) - Ensuring folder: $nameSpaceDir for namespace: \'$nameSpace\'
        mkdir -p $nameSpaceDir

        # Pulling the namespace to its folder
        echo $(logPrefix) - Pulling namespace: \'$nameSpace\' to file: $nameSpaceDir/$nameSpace.yml
        kubectl get namespace $nameSpace --export=true --output=yaml > $nameSpaceDir/$nameSpace.yml || exit

        # Getting list of Kubernetes object types (parsing a given fixed global parameter)
        objectTypes=$(echo -e `echo $INCLUDE_OBJECT_TYPES | sed 's/|/\\\n/g'`);

        # If objcets types were given, iterate one by one.
        [ ! -z "$objectTypes" ] &&
        echo $(logPrefix) - Starting to backup objects of type: \'$objectTypes\' for namespace: \'$nameSpace\' &&
        while read -r objectType; do

            # Getting list of Kubernetes objects of a specific type and set their directory variable
            objects=$(kubectl get $objectType --namespace=$nameSpace --output custom-columns=NAME:.metadata.name | egrep -v "$EXCLUDE_OBJECTS" | grep -v NAME);
            objectTypeDir=$GIT_LOCAL_DIR/$KUBE_CLUSTER_NAME/$nameSpace/$objectType;

            # If objcets found, ensure their directory and iterate one by one.
            [ ! -z "$objects" ] &&
            echo $(logPrefix) - Detected objects of type: \'$objectType\' for namespace: \'$nameSpace\' &&
            echo $(logPrefix) - Ensuring folder $objectTypeDir for objects of type: \'$objectType\' &&
            mkdir -p $objectTypeDir &&
            while read -r object; do

                # Pulling Kubernetes object to its folder or exit if fail (--export=true stripping it from cluster-specific-information)
                echo $(logPrefix) - Pulling object: \'$object\' of type: \'$objectType\' to file: $objectTypeDir/$object.yml
                kubectl get $objectType $object --namespace=$nameSpace --export=true --output=yaml > $objectTypeDir/$object.yml || exit

            done <<< "${objects}" || echo $(logPrefix) - No objects of type \'$objectType\' detected for namespace: \'$nameSpace\'

        done <<< "${objectTypes}" || echo $(logPrefix) - No desired object types were specified

    done <<< "${nameSpaces}" || echo $(logPrefix) - No namespaces detected for backup, exiting gracefully
}

# Main
echo $(logPrefix) "-------------------------------------------------------"
echo $(logPrefix) "Start backuping up Kubernetes objects to Git repository"
echo $(logPrefix) "-------------------------------------------------------"
pullFromKube 
pushToGit
echo $(logPrefix) "---------------------------------------------------------------------"
echo $(logPrefix) "Successfully Finish backuping up Kubernetes objects to Git repository"
echo $(logPrefix) "---------------------------------------------------------------------"
