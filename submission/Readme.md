# Submission Documentation

## 01_install.sh
It installs the test environment, but instead of using Vagrant, it uses a second debian server.
It has 4 main section and can be executed manually from any given section.
*do_100:*  Installs docker and rke and clones project if not yet exists.
*do_200:*  copy ssh_key to k8s server, executes rke up and install kube-bench on the k8s server
*do_300:*  installs audit tools locally: 
           auditd, docker-compose, golang, docker-bench, icdiff, sqlite3, syft, grype, trivy, helm
*do_1000:* creates a setup_summary.txt 

## 02_run_sec_tests.sh
It runs the same tests twice, first as "initial" (see ```initial-_-*.txt``` files as the results) 
and second as "hardened" (see ```hardened-_-*txt``` files as the result). 
The following tests are executed:
- docker-bench
- kube-bench
- Grype and Trivy on the filesystem
and it creates an incident report.

### 021_fix_docker.sh
Includes which were executed to harden the docker daemon. 

### 021_fix_k8s.sh
Copies encryption-config.yaml to k8s server and executes changes to harden the k8s server

### 021_fix_app.sh
Installs dependency for the aiohttp-csrf python modul into the local environment 

## 03_install_runtime_monitoring.sh
Install falco monitoring to k8s

## app.py
Contains the fixed/hardened app.py.

## PNG files and kube_hardening_test_plan.txt, threat_modelling.txt, incident_response_report.txt
Are required documents by the project.

## Other files  
The following files are used in the test environmentas the result of hardening the docker daemon:
daemon.json, docker.rules, docker.service, 

The following file was used to harden the k8s environment:
hardened_cluster.yml, encryption-config.yaml




# Usage

To install the necessary dependencies, run the following command:

```bash
curl -sSL https://raw.githubusercontent.com/varsanyim/nd064-c3-microservices-security-project-starter/refs/heads/master/submission/01_install.sh -o 01_install.sh | tee install.log
```

Ensure you have the required permissions to execute the script.


app : is the hardened/fixed copy of vuln_app

curl -sSL https://raw.githubusercontent.com/varsanyim/nd064-c3-microservices-security-project-starter/refs/heads/master/submission/01_install.sh -o 01_install.sh | tee install.log;