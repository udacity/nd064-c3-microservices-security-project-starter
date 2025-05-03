#!/bin/bash

export PROJECT_DIR=~/nd064-c3-microservices-security-project-starter/starter

helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falco using Helm with the custom values.yaml
helm install falco falcosecurity/falco -f values.yaml --kubeconfig $PROJECT_DIR/kube_config_cluster.yml
kubectl get pods -n falco --kubeconfig $PROJECT_DIR/kube_config_cluster.yml
kubectl logs -n falco -l app=falco-exporter --kubeconfig $PROJECT_DIR/kube_config_cluster.yml

