#!/bin/bash

# Define a global list of fedids
fedid_list=("user-1" "user-2")



add_test_configmap() {
    fedid=$1
    cat <<EOF > ./$fedid/auto/test-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fedid
  namespace: formation-$fedid
data:
  user_fedid: $fedid
EOF
}

# Function to generate user folders
generate_users() {
    # Iterate over the list of fedids
    for fedid in "${fedid_list[@]}"; do
        # Create a folder for each fedid in the working directory
        mkdir -p "./$fedid/manual"
        touch "./$fedid/manual/.gitkeep"
        mkdir -p "./$fedid/auto"
        touch "./$fedid/auto/.gitkeep"
        add_test_configmap $fedid
        echo "Folder created for fedid: $fedid"
    done

    echo "Folder creation completed."
}

# Function to delete user folders
delete_users() {
    # Iterate over the list of fedids
    for fedid in "${fedid_list[@]}"; do
        # Delete the folder for each fedid in the working directory
        if [ -d "./$fedid" ]; then
            rm -r "./$fedid"
            echo "Folder deleted for fedid: $fedid"
        fi
    done

    echo "Folder deletion completed."
}

# Uncomment and call the functions as needed
# generate_users
delete_users
