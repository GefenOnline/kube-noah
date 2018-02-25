#!/bin/bash
# ------------------------------------------------------------------------------
# Syncing Once Kubernetes objects from git repository to the Kubernetes cluster
# ------------------------------------------------------------------------------

# Push Kubernetes objects from the environment folder in git dir to kubernetes cluster
function pushToKube {
    
    # Checking if environment directory doesn't exist, if so exiting gracefully
    if [ ! -d "$GIT_DIR/$ENVIRONMENT" ]; then

        echo $(date) - No environment directory by the name $GIT_DIR/$ENVIRONMENT found.
        echo $(date) - Nothing to do...

    else
        # Checking if environment directory doesn't answering to the directories naming convention
        # Meaning it does't contain two levels of directories, if so exiting with error
        if [ ! "$(ls -A $GIT_DIR/$ENVIRONMENT/*/*/ 2> /dev/null)" ]; then

            echo $(date) - Error : Environment directory by the name $GIT_DIR/$ENVIRONMENT found, but not answering to the directories convention
            echo $(date) - Error : This can be caused by manual repositoy intervention
            echo $(date) - Error : Please keep the convention [ENVIRONMENT]/[NAMESPACE]/[OBJECT_KIND], if you are messing with the repository manually
            echo $(date) - Error : Can not continue... Exiting nervously, restore from Git to Kubernetes failed :'('
            exit 1

        # If domain directories exist
        else
            # Iterating over the objects directories under all the namespaces directories of the environment folder and import objects yaml
            for objectDir in $GIT_DIR/$ENVIRONMENT/*/*/; do

                # Extracting objects namespace of the object directory parent folder
                objectsNameSpace=$(basename $(dirname $objectDir))

                # Importing the legit ones anyway but exit with error if one or more fails
                echo $(date) - Importing for domain directory : $objectDir
                kubectl apply --namespace=$objectsNameSpace -f $objectDir || exit

            done
        fi
    fi  
       
}

# Main
echo $(date) "--------------------------------------------------------------------"
echo $(date) "Sync TLS certificates from Git repository to Kubernetes secrets Once"
echo $(date) "--------------------------------------------------------------------"
pushToKube
echo $(date) - Finish syncing from Git to Kubernetes :')' 
