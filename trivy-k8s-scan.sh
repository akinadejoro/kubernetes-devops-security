#!/bin/bash

# trivy-k8s-scan

echo $imageName #getting Image name from env variable

wk_dir=`pwd`

echo $wk_dir



# git clone $imageName

# export $USER_CREDENTIALS_USR
# export $USER_CREDENTIALS_PSW

# TRIVY_USERNAME=$USER_CREDENTIALS_USR TRIVY_PASSWORD=$USER_CREDENTIALS_PSW docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
# TRIVY_USERNAME=$USER_CREDENTIALS_USR TRIVY_PASSWORD=$USER_CREDENTIALS_PSW docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $imageName

docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity CRITICAL --light $imageName

    # Trivy scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code"

    # Check scan results
    if [[ ${exit_code} == 1 ]]; then
        echo "Image scanning failed. Vulnerabilities found"
        exit 1;
    else
        echo "Image scanning passed. No vulnerabilities found"
    fi;