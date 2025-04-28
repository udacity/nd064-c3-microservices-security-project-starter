#!/bin/bash

# This script is designed to run security tests on 
# - docker
# - docker image(s)
# - Kubernetes cluster
# - flask app

# Exit on any error
set -e

export SUBMISSION=~/nd064-c3-microservices-security-project-starter/submission
export PROJECT_DIR=~/nd064-c3-microservices-security-project-starter/starter
USER_HOST="udacity"
PASS_HOST="UdacityRocks.1!!"
USER_VAGRANT="root"
PASS_VAGRANT="vagrant"
IP_VAGRANT="192.168.50.101"

DOCKER_IMAGE="varsanyim/nd064-c3-microservices-security-project-starter:$TYPE"

do_scan() {
    # Check if the first parameter is provided
    if [ -z "$1" ]; then
    echo "Error: Missing required parameter"
    exit 1
    fi

    # Check if the parameter is either "not_hardened" or "hardened"
    if [[ "$1" != "not_hardened" && "$1" != "hardened" ]]; then
    echo "Error: Invalid parameter. Must be 'not_hardened' or 'hardened'."
    exit 1
    fi

    # Set the TYPE variable
    export TYPE="$1"

    echo "*****************************************************************************"
    echo "Running security scans... $TYPE"
    echo "*****************************************************************************"
    echo -e "\n\n"

    echo "============================================================================="
    echo "Running STRIDE security scan..."
    echo "============================================================================="
    echo "*TODO*"

    echo "============================================================================="
    echo "Running Docker-bench security scan..."
    echo "============================================================================="
    cd ~/docker-bench/
    docker-bench --include-test-output > $SUBMISSION/docker-bench_-_$TYPE.txt
    echo "Docker-bench results saved to $SUBMISSION/docker-bench_-_$TYPE.txt"
    echo "Check for failed findings in the results."
    cd $PROJECT_DIR

    echo "============================================================================="
    echo "Running Kube-bench security scan..."
    echo "============================================================================="
    ssh $USER_VAGRANT@$IP_VAGRANT -t "docker run --pid=host -v /etc:/node/etc:ro -v /var:/node/var:ro -ti rancher/security-scan:v0.2.2 bash && \
        kube-bench  --scored --config-dir=/etc/kube-bench/cfg --benchmark rke-cis-1.6-hardened" > $SUBMISSION/kube-bench_-_$TYPE.txt
    echo "Kube-bench results saved to $SUBMISSION/kube-bench_-_$TYPE.txt"
    echo "Check for failed findings in the results."

    echo "============================================================================="
    echo "Running Grype and Trivy scan on the docker image..."
    echo "============================================================================="
    grype $DOCKER_IMAGE_VULN > $SUBMISSION/grype_docker_-_$TYPE.txt
    echo "Grype scan results saved to $SUBMISSION/grype_docker_-_$TYPE.txt"
    echo "Check for any vulnerabilities listed in the results."
    trivy image $DOCKER_IMAGE_VULN > $SUBMISSION/trivy_docker_-_$TYPE.txt
    echo "Trivy scan results saved to $SUBMISSION/trivy_docker_-_$TYPE.txt"
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
# add Docker STRIDE threat model evaluation
# add K8S STRIDE threat model evaluation
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

exit

# Create a mock incident response report based on your test results
echo "Creating mock incident response report..."
cat <<EOF > $SUBMISSION/incident_response_report.txt
1. Incident commander name: Martina Wille
2. Executive Summary of what happened: A security event was triggered due to XSS in Flask app. An attacker exploited a vulnerability in the Flask app.
3. Summary of what was affected: The user data was exposed.
4. Summmry of the impact: The exposure led to potential data leaks.
5. Summary of the remediation steps: Fixed XSS, patched vulnerable libraries.
6. Summary of lessons learned: Always validate user input and review libraries in pipelines.


EOF
echo "Incident response report saved to $SUBMISSION/incident_response_report.txt"


echo "Script completed."

cd $SUBMISSION