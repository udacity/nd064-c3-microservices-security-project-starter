#!/bin/bash

# This script is designed to initalize an environment for running security tests on a microservices project.
# It sets up Docker, Vagrant, and various security tools, and runs commands to prepare the environment.

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_init.sh"

START_FROM="${1:-all}"   # Default to 'all' if no argument
RUN=false



DOCKER_IMAGE="varsanyim/nd064-c3-microservices-security-project-starter:$TYPE"

run() {
    local section="$1"
    shift
    if [[ "$START_FROM" == "all" || "$RUN" == true || "$START_FROM" == "$section" ]]; then
        RUN=true
        echo "=== Running section: $section ==="
        "$@"
        read -p "Do you want to continue? (y/n): " answer
        if [[ "${answer,,}" != "y" ]]; then
            echo "Aborted."
            exit 1
        fi
    fi
}


do_100() {
    line
    echo "Init Docker"
    sudo systemctl start docker
    sudo chmod 666 /var/run/docker.sock
    if ! getent group docker > /dev/null; then
        sudo groupadd docker
    fi
    sudo usermod -aG docker root
    echo "Login to Docker Hub"
    docker login

    line
    echo "Clone the project and init .ssh/known_hosts"
    if [ ! -d "$PROJECT_DIR" ]; then
        cd ~
        git clone --recurse-submodules https://github.com/varsanyim/nd064-c3-microservices-security-project-starter.git
    fi
    cd $PROJECT_DIR
    git pull
    if [ ! -d "$SUBMISSION" ]; then
        mkdir -p $SUBMISSION
        git add .
        git commit -m "submission directory added"
        git push
    fi

    if [ -f ~/.ssh/known_hosts ]; then
        mv ~/.ssh/known_hosts ~/.ssh/known_hosts.$(date +%Y%m%d_%H%M%S)
    fi

    curl -LO https://github.com/rancher/rke/releases/download/v1.4.10/rke_linux-amd64
    chmod +x rke_linux-amd64
    sudo mv rke_linux-amd64 /usr/local/bin/rke
    line

}

do_200() {
    echo "Execute ssh-copy-id"; 

    ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@$K8S_IP
    sleep 10
    echo "SSH key copied to $K8S_IP."
    line
    rke up --ignore-docker-version --config $PROJECT_DIR/cluster.yml
    echo "RKE is up! Check the logs and Continuing with setup..."
    line
    kubectl --kubeconfig kube_config_cluster.yml get nodes
    kubectl --kubeconfig kube_config_cluster.yml get pods -A
    # docker build -t varsanyim/nd064-c3-microservices-security-project-starter:latest . --no-cache=true
    # docker push varsanyim/nd064-c3-microservices-security-project-starter:latest
    # docker tag varsanyim/nd064-c3-microservices-security-project-starter:latest varsanyim/nd064-c3-microservices-security-project-starter:not_hardened

    line
    # echo "Install & run kube-bench as docker"
    # ssh root@$K8S_IP 'docker run --pid=host -v /etc:/node/etc:ro -v /var:/node/var:ro rancher/security-scan:v0.2.2 bash -c "kube-bench run --targets etcd,master,controlplane,policies --scored --config-dir=/etc/kube-bench/cfg --benchmark rke-cis-1.6-hardened"' > $SUBMISSION/kube-bench-after_install_results.txt
    echo "Install kube-bench"
    ssh root@$K8S_IP 'sudo apt update; sudo apt install -y git curl jq && \
        curl -LO https://github.com/aquasecurity/kube-bench/releases/download/v0.10.6/kube-bench_0.10.6_linux_amd64.deb && \
        dpkg -i kube-bench_0.10.6_linux_amd64.deb && \
        apt-get install -f'
    read -p "Press enter to continue"
}

do_300() {
    sudo apt install -y auditd audispd-plugins # requirement for docker-bench
    sudo systemctl enable auditd
    sudo systemctl start auditd
    # sudo apt-get update
    sudo apt-get install golang -y
    go version
    go env | grep GOENV

    sudo curl -SL https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    cd /usr/local/bin/
    sudo chmod +x docker-compose

    echo "Install: 
    python3 -m pip install icdiff"
    read -p "Execute manually in a Python venc, and then press enter to continue"

    sudo apt-get install sqlite3 -y
    sqlite3 --version

    sudo curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin
    syft --version

    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin
    grype version

    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.18.3
    trivy --version

    echo "Clone & install docker-bench"
    if [ ! -d ~/docker-bench ]; then
        cd ~
        git clone https://github.com/aquasecurity/docker-bench.git
        cd docker-bench/
        go build -o docker-bench
        cd $PROJECT_DIR
    fi
    echo "Kube-bench is installed after RKE is up"

    # Add Helm repo and update it
    curl https://get.helm.sh/helm-v3.9.1-linux-amd64.tar.gz -o helm-v3.9.1-linux-amd64.tar.gz
    tar -zxvf helm-v3.9.1-linux-amd64.tar.gz
    sudo mv linux-amd64/helm /usr/local/bin/helm

    # Verify Helm installation
    helm version

}

# Function to capture version information and configurations
do_1000() {
    SUMMARY_FILE="$SUBMISSION/setup_summary.txt"
    echo "=== Capturing version information and configurations ===" >> $SUMMARY_FILE
    echo "Environment setup on $(date)" >> $SUMMARY_FILE
    echo "=============================" >> $SUMMARY_FILE

    echo "Docker version: $(docker --version)" >> $SUMMARY_FILE
    echo "Docker Compose version: $(docker-compose --version)" >> $SUMMARY_FILE
    echo "Go version: $(go version)" >> $SUMMARY_FILE
    echo "Syft version: $(syft --version)" >> $SUMMARY_FILE
    echo "Grype version: $(grype version)" >> $SUMMARY_FILE
    echo "Trivy version: $(trivy --version)" >> $SUMMARY_FILE
    echo "SQLite3 version: $(sqlite3 --version)" >> $SUMMARY_FILE
    echo "RKE version: $(rke --version)" >> $SUMMARY_FILE
    echo "Kube-bench version: $(kube-bench --version)" >> $SUMMARY_FILE
    echo "=============================" >> $SUMMARY_FILE

    echo "Docker configuration:" >> $SUMMARY_FILE
    cat /etc/docker/daemon.json >> $SUMMARY_FILE || echo "No Docker daemon.json configuration" >> $SUMMARY_FILE

    echo "Kube-bench configuration:" >> $SUMMARY_FILE
    ssh root@$K8S_IP 'docker run --pid=host -v /etc:/node/etc:ro -v /var:/node/var:ro rancher/security-scan:v0.2.2 bash -c "cat /etc/kube-bench/cfg/kube-bench-config.yaml"' >> $SUMMARY_FILE || echo "No Kube-bench configuration" >> $SUMMARY_FILE

    echo "=============================" >> $SUMMARY_FILE
    cat $SUMMARY_FILE
}

#workflow
run do_100 do_100
run do_200 do_200
run do_300 do_300
run do_1000 do_1000
echo "=== Environment setup completed ==="


