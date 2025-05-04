#!/bin/bash
# set -e

export K8S_IP="192.168.2.155"
export SUBMISSION=~/nd064-c3-microservices-security-project-starter/submission
export PROJECT_DIR=~/nd064-c3-microservices-security-project-starter/starter
export K="--kubeconfig $PROJECT_DIR/kube_config_cluster.yml"

echo ">>> Variables: 
K8S_IP      = $K8S_IP
SUBMISSION  = $SUBMISSION 
PROJECT_DIR = $PROJECT_DIR
K           = $K        
(Usage: kubectl $K get pods -n monitoring)
"

line() {
    echo "================================================================================"
}
