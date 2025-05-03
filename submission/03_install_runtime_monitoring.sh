#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_init.sh"

line
echo "Install Falco on Host (via https://falco.org/docs/setup/packages/)"
ssh root@$K8S_IP '\
set -e
echo ">>> Install GPG" ;\
apt-get install gnupg2
echo ">>> Download Falco GPG key and save it locally" ;\
curl -fsSL https://falco.org/repo/falcosecurity-packages.asc -o falco-archive-keyring.gpg; \
echo ">>> Import Falco GPG key" ;\
rm -f /usr/share/keyrings/falco-archive-keyring.gpg; \
gpg --batch --no-tty --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg falco-archive-keyring.gpg; \
echo ">>> add falco repository to apt sources" ;\
echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | \
sudo tee -a /etc/apt/sources.list.d/falcosecurity.list; \
echo ">>> update apt and install falco" ;\
sudo apt-get update -y; \
sudo apt install -y dkms make linux-headers-$(uname -r); 
echo ">>> If you use falcoctl driver loader to build the eBPF probe locally you need also clang toolchain" ;
sudo apt install -y clang llvm; 
echo ">>> You can install also the dialog package if you want it ";
sudo apt install -y dialog; 
echo ">>> Finally... install falco" ;
FALCO_FRONTEND=noninteractive apt-get install -y falco; 
sudo apt-get install -y falco; 
echo ">>> Finito!" ;\
echo ">>> You can check the falco version with: falco --version" ;
sudo systemctl enable falco
sudo systemctl start falco
sudo systemctl status falco
'

echo "vim /etc/systemd/system/falco.service: 
[Unit]
Description=Falco - Cloud-native runtime security
Documentation=https://falco.org/
After=syslog.target network.target

[Service]
Type=simple
ExecStart=/usr/bin/falco
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

===============================================================================
sudo systemctl daemon-reload
sudo systemctl enable falco
sudo systemctl start falco
sudo systemctl status falco

"

read -p "Make the manual changes to /etc/systemd/system/falco.service on the Host and then...
press [Enter] key to continue..."

line
echo "Install Falco on Kubernetes using Helm"
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falco using Helm with the custom values.yaml
helm install --kubeconfig $PROJECT_DIR/kube_config_cluster.yml \
  falco falcosecurity/falco \
  --namespace falco --create-namespace --set falco.grpc.enabled=true --set falco.grpc_output.enabled=true
# helm install falco falcosecurity/falco -f values.yaml --kubeconfig $PROJECT_DIR/kube_config_cluster.yml

echo ">>> check if falco is running/healthy"
echo "Namespaces:"
kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml get namespace
echo "Pods:"
kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml get pods --namespace falco 
echo "DaemonSets:"
kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml get ds --namespace falco 
echo "Falco Service Account:"
kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml get ds falco --namespace falco -o yaml | grep serviceAcc
echo "Falco exporter Log"
kubectl logs -n falco -l app=falco-exporter --kubeconfig $PROJECT_DIR/kube_config_cluster.yml


echo "Check  falco.yaml in Pod: The grpc and grpc_output flags should be set to true"
kubectl config set-cluster local --server=https://$K8S_IP:6443 --insecure-skip-tls-verify=true --kubeconfig $PROJECT_DIR/kube_config_cluster.yml
POD_NAME=$(kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml get pods --namespace falco -o jsonpath='{.items[0].metadata.name}')
kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml exec -it $POD_NAME --namespace falco -c falco -- cat /etc/falco/falco.yaml | grep -A 5 -i grpc

line
echo "Add intruder (via course)"
kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml exec -it $POD_NAME --namespace falco -c falco -- /bin/bash -c '
if ! id "best_hacker" &>/dev/null; then
  adduser --disabled-password --gecos "" best_hacker
fi
'

echo "You can check 'best_hacker' with: 
kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml logs $POD_NAME --namespace falco -c falco| grep best_hacker
"

read -p "Press [Enter] key to continue... with Grafana and Prometheus installation"

line
echo "Install Grafana and Prometheus on Kubernetes using Helm"

## Install the CustomResourceDefinition resources separately
# kubectl apply --kubeconfig $PROJECT_DIR/kube_config_cluster.yml  --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/v1.3.1/cert-manager.yaml  
## Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update
## Install the cert-manager Helm chart
helm install --kubeconfig $PROJECT_DIR/kube_config_cluster.yml cert-manager jetstack/cert-manager  --namespace cert-manager --create-namespace 

kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml get pods -A
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update 
## Install kube-prometheus-stack, specific version
helm install --kubeconfig $PROJECT_DIR/kube_config_cluster.yml prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace --generate-name 

## Check your Prometheus release name
helm list --kubeconfig $PROJECT_DIR/kube_config_cluster.yml --all --all-namespaces
## You should have 6 Prometheus-related pods up. 
kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml get pods --namespace monitoring
## Verify all pods are Running fine.
kubectl --kubeconfig $PROJECT_DIR/kube_config_cluster.yml get pods -A

read -p "Press [Enter] key to continue... if everything is ok"


line
echo "Creating custom Falco rule..."
cat <<EOF >> falco_rules.local.yaml
- rule: Sensitive file read
  desc: Detects attempts to read sensitive files
  condition: evt.type in (open) and fd.name startswith /etc/
  output: Sensitive file accessed
  priority: CRITICAL
EOF
echo "Custom Falco rule added."

# Step 13: Test Custom Falco Rule (Optional)
echo "Testing custom Falco rule..."
# Simulate a sensitive file read by accessing a file in /etc/
echo "Testing Falco rule..." > /etc/test_file.txt
echo "Simulated sensitive file read to trigger the custom rule."

# Step 14: Monitor Grafana for Custom Falco Rule (Optional)
echo "Checking Grafana for custom rule trigger..."
# The output should appear on your Grafana dashboard
echo "Check Grafana for the sensitive file access trigger."
