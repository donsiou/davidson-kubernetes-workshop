#!/bin/bash

# Define a global list of fedids
fedid_list=("z23ataba" "akhald20" "alecar15" "abelmi19" "z08fbois" "gdelbe24" "z08jbech" "mmazoy08" "z03mlafr" "z08mkemm" "mtayab16" "z24mazan" "z14rcaro" "ssalhi26" "z24slarr" "z25tpont" "xnguye26" "z18oelkh" "z26adiev")



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
