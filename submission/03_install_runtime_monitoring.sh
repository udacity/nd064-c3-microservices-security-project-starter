#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_init.sh"

line
echo "Install Falco on Host (via https://falco.org/docs/setup/packages/)"
ssh root@$K8S_IP '\
set -e
echo ">>> Install GPG" ;\
apt-get install gnupg2 -y; \
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
falco --version
# sudo systemctl enable falco
# sudo systemctl start falco
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
sudo systemctl restart falco
sudo systemctl status falco

"

read -p "Make the manual changes to /etc/systemd/system/falco.service on the Host and then...
press [Enter] key to continue..."

line
echo ">>> Create namespaces"
kubectl $K create namespace falco
kubectl $K create namespace monitoring
# echo ">>> Add persistent volume "
# kubectl $K apply -f $SUBMISSION/prometheus-storage-config.yaml

echo ">>> Add repos to Helm"
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts $K 
helm repo add grafana https://grafana.github.io/helm-charts $K 
helm repo update

line
echo "Install Falco on Kubernetes using Helm"
helm upgrade --install  $K \
  falco falcosecurity/falco \
  --namespace falco \
  --set falco.grpc.enabled=true --set falco.grpc_output.enabled=true  --set falcosidekick.enabled=true

# helm install falco falcosecurity/falco -f values.yaml $K

echo ">>> check if falco is running/healthy"
kubectl $K get all -A |  grep -iE 'NAME|falco'
echo "Falco Service Account:"
kubectl $K get ds falco --namespace falco -o yaml | grep serviceAcc

echo "Check  falco.yaml in Pod: The grpc and grpc_output flags should be set to true"
# kubectl config set-cluster local --server=https://$K8S_IP:6443 --insecure-skip-tls-verify=true $K
FALCO_POD=$(kubectl $K get pods --namespace falco -o jsonpath='{.items[0].metadata.name}')
output=$(kubectl $K exec -it $FALCO_POD --namespace falco -c falco -- cat /etc/falco/falco.yaml | grep -A 5 -i grpc )
count=$(echo -e "$output" | grep -c "enabled: true")
# Check if the count is exactly 2
if [ "$count" -ne 2 ]; then
  echo "Error: Expected 2 occurrences of 'enabled: true', but found $count."
  echo -e "$output"
  read -n 1 -s -r -p "Press any key to continue..."
else
  echo ">>> Falco is running with gRPC enabled"
fi

line
echo "Install Prometheus, Grafana and Falco-Exporter on K8S using Helm"
helm $K upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30001 \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30090 \
  --set prometheus.persistentVolume.enabled=false \
  --set grafana.persistence.enabled=false
#  
helm $K upgrade --install falco-exporter falcosecurity/falco-exporter \
  --namespace monitoring \
  --set service.type=NodePort \
  --set service.nodePort=30002 \
  --set service.port=9443 \
  --set service.targetPort=9443 \
  --set service.clusterIP="" \
  --set grafanaDashboard.enabled=true

kubectl $K label service falco-exporter release=kube-prometheus-stack -n monitoring
kubectl $K label svc falco-exporter app.kubernetes.io/name=falco-exporter -n monitoring
kubectl $K apply -f falco-exporter-servicemonitor.yaml
kubectl $K label servicemonitor falco-exporter release=kube-prometheus-stack -n monitoring --overwrite

echo ">>> Exposed Ports:
Expose Prometheus server on NodePort 30090:
Expose Grafana on NodePort 30001:
Expose Falco Exporter on NodePort 30002 (ensure clusterIP isn't set to None):
"
kubectl $K get all -n monitoring 
read -p "Press [Enter] key to continue... if everything is ok"
kubectl $K get all -n monitoring > monitoring-after_install.txt

# Get the Grafana admin password 
export GRAFANA_ADMIN_PASSWORD=$(kubectl $K get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)
echo ">>>> Grafana URL: http://$K8S_IP:3000"
echo ">>>> Grafana admin password: $GRAFANA_ADMIN_PASSWORD" # prom-operator

# kubectl get svc grafana -n monitoring $K


# kubectl expose svc prometheus-server --namespace monitoring --type=NodePort --name=prometheus-nodeport $K
# kubectl expose svc grafana --namespace monitoring --type=NodePort --name=grafana-nodeport $K

export FALCO_EXPORTER_POD=$(kubectl $K get pods -n monitoring --no-headers | grep '^falco-exporter' | awk '{print $1}')
# kubectl expose pod $FALCO_EXPORTER_POD --namespace monitoring --type=NodePort --name=falco-exporter-nodeport $K
kubectl $K get all -A |  grep -iE 'NAME|falco' > kube_falco_installed.txt


export PROMETHEUS_POD=$(kubectl $K get pods -n monitoring --no-headers | grep '^prometheus-server' | awk '{print $1}'); echo "Prometheus Pod: $PROMETHEUS_POD"
curl -s http://$K8S_IP:30090/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job == "falco-exporter")'


# line
# echo " Edit the configmap prometheus-server to add the falco-exporter job"
#   - job_name: 'falco-exporter'
#     static_configs:
#       - targets: ['falco-exporter.monitoring.svc.cluster.local:9443']
# "
# kubectl $K -n monitoring edit configmap prometheus-server

# read -p "Press [Enter] key to continue... if everything is ok"
# kubectl $K -n monitoring delete pod $PROMETHEUS_POD
# export PROMETHEUS_POD=$(kubectl $K get pods -n monitoring --no-headers | grep '^prometheus-server' | awk '{print $1}'); echo "Prometheus Pod: $PROMETHEUS_POD"
# curl -s http://$K8S_IP:30090/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job == "falco-exporter")'


line
METRIC_FILE=$SUBMISSION/metrics_01_before_intruder.txt
echo -e "Falco Exporter Metrics for falco events: " > $METRIC_FILE
curl -s http://192.168.2.155:30002/metrics| grep ^falco_events >> $METRIC_FILE
echo -e "Prometheus Metrics for falco events: " >> $METRIC_FILE
curl -s "http://$K8S_IP:30090/api/v1/query?query=falco_events" | jq -r '.data.result[] | "\(.metric.rule)\t\(.value[1])"' >> $METRIC_FILE


echo "Add intruder (via course)"
kubectl $K exec -it $FALCO_POD --namespace falco -c falco -- /bin/bash -c '
if ! id "best_hacker" &>/dev/null; then
  adduser --disabled-password --gecos "" best_hacker
fi
cat /etc/passwd | grep best_hacker
cat /etc/shadow | grep best_hacker
'

sleep 30
METRIC_FILE=$SUBMISSION/metrics_02_after_intruder.txt
echo -e "Falco Log after intruder: " > $METRIC_FILE
kubectl $K logs $FALCO_POD --namespace falco -c falco| grep best_hacker >> $METRIC_FILE
echo -e "Falco Exporter Metrics for falco events: " >> $METRIC_FILE
curl -s http://$K8S_IP:30002/metrics| grep ^falco_events >> $METRIC_FILE
echo -e "Prometheus Metrics for falco events: " >> $METRIC_FILE
curl -s "http://$K8S_IP:30090/api/v1/query?query=falco_events" | jq -r '.data.result[] | "\(.metric.rule)\t\(.value[1])"' >>$METRIC_FILE


line

echo ">>>> Grafana URL: http://$K8S_IP:3000"
echo ">>>> Grafana admin password: $GRAFANA_ADMIN_PASSWORD"


exit



















line
echo "Install Grafana and Prometheus on Kubernetes using Helm"
## Install the CustomResourceDefinition resources separately
kubectl apply $K  --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.17/cert-manager.yaml  
## Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update
## Install the cert-manager Helm chart
# helm upgrade --install  $K cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace

kubectl $K get pods -A
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update 
## Install kube-prometheus-stack, specific version
helm install $K prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace --generate-name 

## Check your Prometheus release name
helm list $K --all --all-namespaces
## You should have 6 Prometheus-related pods up. 
kubectl $K get pods --namespace monitoring
## Verify all pods are Running fine.
kubectl $K get pods -A

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
