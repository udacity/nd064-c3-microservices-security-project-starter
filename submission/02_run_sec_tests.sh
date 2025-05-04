#!/bin/bash

# This script is designed to run security tests on 
# - docker
# - docker image(s)
# - Kubernetes cluster
# - flask app


source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_init.sh"


DOCKER_IMAGE_initial=~/nd064-c3-microservices-security-project-starter/vuln_app/
DOCKER_IMAGE_hardened="$SUBMISSION/app"

do_scan() {
    # Check if the first parameter is provided
    if [ -z "$1" ]; then
    echo "Error: Missing required parameter"
    exit 1
    fi

    # Check if the parameter is either "initial" or "hardened"
    if [[ "$1" != "initial" && "$1" != "hardened" ]]; then
    echo "Error: Invalid parameter. Must be 'initial' or 'hardened'."
    exit 1
    fi


    # Set the TYPE variable
    export TYPE="$1"
    export DOCKER_IMAGE="DOCKER_IMAGE_$TYPE"

    echo "*****************************************************************************"
    echo "Running security scans... $TYPE"
    echo ${!DOCKER_IMAGE}
    echo "*****************************************************************************"
    echo -e "\n\n"

    echo "============================================================================="
    echo "Running Docker-bench security scan..."
    echo "============================================================================="
    cd ~/docker-bench/
    pwd
    sudo ./docker-bench --include-test-output > $SUBMISSION/$TYPE-_-docker-bench.txt
    echo "Docker-bench results saved to $SUBMISSION/$TYPE-_-docker-bench.txt"
    echo "Check for failed findings in the results."
    cd $PROJECT_DIR

    echo "============================================================================="
    echo "Running Kube-bench security scan..."
    echo "============================================================================="
    ssh root@$K8S_IP 'kube-bench run --targets etcd,master,controlplane,policies --scored --config-dir=/etc/kube-bench/cfg --benchmark rke-cis-1.24' > $SUBMISSION/$TYPE-_-kube-bench.txt
    echo "Kube-bench results saved to $SUBMISSION/$TYPE-_-kube-bench.txt"
    echo "Check for failed findings in the results."

    echo "============================================================================="
    echo "Running Grype and Trivy scan on the docker image..."
    echo "============================================================================="
    echo -e "grype DOCKER_IMAGE_$TYPE > $SUBMISSION/$TYPE-_-grype_docker.txt"
    grype dir:${!DOCKER_IMAGE} > $SUBMISSION/$TYPE-_-grype_docker.txt
    echo "Grype scan results saved to $SUBMISSION/$TYPE-_-grype_docker.txt"
    echo -e "Check for any vulnerabilities listed in the results.\n\n"
    docker run --rm -v ${!DOCKER_IMAGE}:/app aquasec/trivy fs app > $SUBMISSION/$TYPE-_-trivy_flask.txt
    # sudo trivy fs ${!DOCKER_IMAGE} > $SUBMISSION/$TYPE-_-trivy_flask.txt
    echo "Trivy scan results saved to $SUBMISSION/$TYPE-_-trivy_flasr.txt"
    echo "Check for vulnerabilities in the image."

}

while true; do
    read -p "Do you want an inital scan? " yn
    case $yn in
        [Yy]* ) do_scan "initial"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "============================================================================="
echo " TODO "
echo "============================================================================="
# harden docker image
# sign docker image
# define operational test plane for K8S hardening? 
# baseline K8S hardening
# fix python flask app
# add runtime monitoring
# Q: what to do wth threat_modelling_template.txt?


while true; do
    read -p "Do you wish to continue with hardened code? " yn
    case $yn in
        [Yy]* ) do_scan "hardened"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


echo "Script completed."

cd $SUBMISSION