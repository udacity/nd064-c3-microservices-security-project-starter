#!/bin/bash

# This script is designed to initalize an environment for running security tests on a microservices project.
# It sets up Docker, Vagrant, and various security tools, and runs commands to prepare the environment.

set -e
START_FROM="${1:-all}"   # Default to 'all' if no argument
RUN=false

export SUBMISSION=~/nd064-c3-microservices-security-project-starter/submission
export PROJECT_DIR=~/nd064-c3-microservices-security-project-starter/starter
USER_HOST="udacity"
PASS_HOST="UdacityRocks.1!!"
USER_VAGRANT="root"
PASS_VAGRANT="vagrant"
IP_VAGRANT="192.168.50.101"

DOCKER_IMAGE="varsanyim/nd064-c3-microservices-security-project-starter:$TYPE"


run() {
    local section="$1"
    shift
    if [[ "$START_FROM" == "all" || "$RUN" == true || "$START_FROM" == "$section" ]]; then
        RUN=true
        echo "=== Running section: $section ==="
        "$@"
    fi
}


do_100() {
    echo "Init Docker"
    sudo systemctl start docker
    sudo chmod 666 /var/run/docker.sock
    sudo groupadd docker
    sudo usermod -aG docker root
    docker login -u varsanyim 

    echo "Clone the project and init .ssh/known_hosts"
    git clone --recurse-submodules https://github.com/varsanyim/nd064-c3-microservices-security-project-starter.git
    cd $PROJECT_DIR
    git submodule update --init --recursive # might not be needed
    git pull
    mkdir -p $SUBMISSION
    git add .
    git commit -m "submission directory added"
    git push

    mv ~/.ssh/known_hosts ~/.ssh/known_hosts

    rke --version
}

do_200() {
    rm nohup.log
    nohup bash -c '( 
        vagrant up > vagrant_up.log 2>&1 && 
        echo "Host credentials: $USER_HOST : $PASS_HOST"; 
        echo "Vagrant: $IP_VAGRANT $USER_VAGRANT : $PASS_VAGRANT"; 
        echo "Execute ssh-copy-id: Provide two different passwords when prompted. The first password is the host machine'\''s admin password, [$PASS_HOST] . The second password is the Node'\''s password, [$PASS_VAGRANT]."; 
        ssh-copy-id -i ~/.ssh/id_rsa $USER_VAGRANT@$IP_VAGRANT &&
        rke up --ignore-docker-version --config cluster.yml &&
        # while [ "$(kubectl --kubeconfig kube_config_cluster.yml get nodes | tail -n +2 | wc -l)" -lt 2 ]; do rke up --ignore-docker-version; sleep 10; done

    )' > nohup.log 2>&1 &
    export NOHUP_PID=$!
    echo "Vagrant and RKE setup is starting with PID $NOHUP_PID"
}

do_300() {
    # sudo zypper addrepo https://download.opensuse.org/repositories/devel:/languages:/go/15.4/devel:languages:go.repo
    sudo zypper --non-interactive refresh
    # sudo zypper install go1.19
    sudo zypper --non-interactive in go go-doc
    go version
    go env | grep GOENV

    sudo curl -SL https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    cd /usr/local/bin/
    sudo chmod +x docker-compose

    python3 -m pip install icdiff

    sudo zypper --non-interactive in sqlite3
    sqlite3 --version

    sudo curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin
    syft --version

    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin
    grype version

    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.18.3
    trivy --version

    echo "Clone & install docker-bench"
    cd ~
    git clone https://github.com/aquasecurity/docker-bench.git
    cd docker-bench/
    go build -o docker-bench
    ./docker-bench --include-test-output > docker-bench.txt    
    cd $PROJECT_DIR
    echo "Kube-bench is installed after RKE is up"
}

do_400() {
    echo "Waiting for Vagrant to finish..."
    wait $NOHUP_PID
    echo "Vagrant is now up! Check the logs and Continuing with setup..."
    touch nohup.log
    less nohup.log
}

do_500() {
    kubectl --kubeconfig kube_config_cluster.yml get nodes
    kubectl --kubeconfig kube_config_cluster.yml get pods -A
    docker build -t varsanyim/nd064-c3-microservices-security-project-starter:latest . --no-cache=true
    docker push varsanyim/nd064-c3-microservices-security-project-starter:latest
    docker tag varsanyim/nd064-c3-microservices-security-project-starter:latest varsanyim/nd064-c3-microservices-security-project-starter:not_hardened

    # echo "Clone & install kube-bench (quit from DOCKER AND VAGRANT after finishing)"
    # ssh $USER_VAGRANT@$IP_VAGRANT -t "docker run --pid=host -v /etc:/node/etc:ro -v /var:/node/var:ro -ti rancher/security-scan:v0.2.2 bash && \
    # kube-bench run --targets etcd,master,controlplane,policies --scored --config-dir=/etc/kube-bench/cfg --benchmark rke-cis-1.6-hardened; bash"

}

# Function to capture version information and configurations
capture_version_info() {
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
    cat ssh $USER_VAGRANT@$IP_VAGRANT -t "docker run --pid=host -v /etc:/node/etc:ro -v /var:/node/var:ro -t rancher/security-scan:v0.2.2 bash && \
    cat /etc/kube-bench/cfg/kube-bench-config.yaml " >> $SUMMARY_FILE || echo "No Kube-bench configuration" >> $SUMMARY_FILE

    echo "=============================" >> $SUMMARY_FILE
}

#workflow
run do_100 do_100
run do_200 do_200
run do_300 do_300
run do_400 do_400
run do_500 do_500
run capture_version_info capture_version_info 