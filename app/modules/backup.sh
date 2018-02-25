#!/bin/bash
# -------------------------------------------
# Backup Kubernetes objects to Git repository
# -------------------------------------------

# Push to Git repository new changes if found
function pushToGit {

    # Collect Git status output
    statusOutput=$(git --git-dir=$GIT_DIR/.git --work-tree=$GIT_DIR status -s)

    # Checking for changes - add, commit, pull and push if necessary
    if [ ! -z "$statusOutput" ]; then

    	echo $(logPrefix) - New changes detected: $statusOutput
    	git --git-dir=$GIT_DIR/.git --work-tree=$GIT_DIR add -A
    	git --git-dir=$GIT_DIR/.git --work-tree=$GIT_DIR commit -am "Automatic changes by by tlser service"

    	# Pulling changes or exit if there is a merge conflict
        echo $(logPrefix) - Pulling changes from the Git repository
    	git --git-dir=$GIT_DIR/.git --work-tree=$GIT_DIR pull --no-edit || exit

	    # Pushing changes or exit if changes where still made someplace else between the last pull (which is the command above) to this push
    	git --git-dir=$GIT_DIR/.git --work-tree=$GIT_DIR push || exit
    	echo $(logPrefix) - New changes successfully pushed to the Git repository.

    else
        echo $(logPrefix) - No new changes were found.
    fi

}

# Exports Kubernetes TLS certificates secrets as yaml files to the git folder
function pullFromKube {
    
    # Get list of filtered Kubernetes namespaces 
    nameSpaces=$(kubectl get namespaces --output custom-columns=NAME:.metadata.name | egrep -v "$EXCLUDE_NAMESPACES" | grep -v NAME);

    # If namespaces were found
    [ ! -z "$nameSpaces" ] && echo $(logPrefix) - Detected namespaces: \'$nameSpaces\' for backup &&
    while read -r nameSpace; do

        # Creating folder for the namespace if absent
        nameSpaceDir=$GIT_DIR/$ENVIRONMENT/$nameSpace
        [ ! -d "$nameSpaceDir" ] && echo $(logPrefix) - Creating folder $nameSpaceDir for namespace: \'$nameSpace\' && mkdir -p $nameSpaceDir

        # Pulling the namespace to its folder
        echo $(logPrefix) - Pulling namespace: $nameSpace...
        kubectl get namespace $nameSpace --export=true --output=yaml > $nameSpaceDir/$nameSpace.yml || exit

        # Getting list of Kubernetes object types
        objectTypes=$(echo -e `echo $INCLUDE_OBJECT_TYPES | sed 's/|/\\\n/g'`);
        [ ! -z "$objectTypes" ] && echo $(logPrefix) - Starting to backup objects of type: \'$objectTypes\' for namespace: \'$nameSpace\' &&
        while read -r objectType; do

            # Creating folder for the object type if absent
            objectTypeDir=$GIT_DIR/$ENVIRONMENT/$nameSpace/$objectType
            [ ! -d "$objectTypeDir" ] && echo $(logPrefix) - Creating folder $objectTypeDir for objects of type: \'$objectType\' && mkdir -p $objectTypeDir

            # Getting list of Kubernetes objects of a specific type 
            objects=$(kubectl get $objectType --namespace=$nameSpace --output custom-columns=NAME:.metadata.name | egrep -v "$EXCLUDE_OBJECTS" | grep -v NAME);
            [ ! -z "$objects" ] && echo $(logPrefix) - Detected objects of type \'$objectType\' for namespace: \'$nameSpace\' &&
            while read -r object; do

                # Pulling Kubernetes object to its folder or exit if fail (--export=true stripping it from cluster-specific-information)
                echo $(logPrefix) - Pulling object: \'$object\' of type: \'$objectType\' to file: $objectTypeDir/$object.yml
                kubectl get $objectType $object --namespace=$nameSpace --export=true --output=yaml > $objectTypeDir/$object.yml || exit

            done <<< "${objects}" || echo $(logPrefix) - No objects of type \'$objectType\' detected for namespace: \'$nameSpace\'

        done <<< "${objectTypes}" || echo $(logPrefix) - No desired object types were specified

    done <<< "${nameSpaces}" || echo $(logPrefix) - No namespaces detected for backup, exiting gracefully 

}

# Main
echo $(logPrefix) "-------------------------------------------"
echo $(logPrefix) "Backup Kubernetes objects to Git repository"
echo $(logPrefix) "-------------------------------------------"
pullFromKube 
#pushToGit
