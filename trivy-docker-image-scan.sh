#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo $dockerImageName

docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light $dockerImageName
docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName

    # Trivy Scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code"

    # Check scan results
    if [ "${exit_code}" == 1 ];
    then
        echo "Image scanning failed. CRITICAL Vulnerability found"
        exit 1;
    else
        echo "Image scanning passed. No CRITICAL Vulnerability found"
    fi;