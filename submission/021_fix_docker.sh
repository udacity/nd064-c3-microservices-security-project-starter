#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_init.sh"


mkdir -p /etc/docker/certs
cd /etc/docker/certs

openssl req -newkey rsa:4096 -nodes -keyout server-key.pem -x509 -days 365 -out server-cert.pem -subj "/CN=localhost"


# Generate CA
openssl genrsa -out ca-key.pem 4096
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem -subj "/CN=docker-ca"

# Generate server cert
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=$(hostname)" -new -key server-key.pem -out server.csr
openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -sha256

# Set permissions
chmod 600 *.pem
sudo chown root:root /etc/docker/certs/*
sudo chmod 444 /etc/docker/certs/*


echo "Update the following files manually:"

echo 'sudo vim /etc/audit/rules.d/docker.rules

# Audit rules for Docker directories
-w /var/lib/docker -p wa -k docker
-w /etc/docker -p wa -k docker
-w /usr/bin/docker -p x -k docker
-w /run/containerd -p wa -k docker
-w /docker -p wa -k docker

# Audit rules for Docker binaries and services
-w /lib/systemd/system/docker.service -p wa -k docker
-w /etc/systemd/system/docker.service -p wa -k docker
-w /usr/bin/containerd -p wa -k docker
-w /usr/bin/containerd-shim -p wa -k docker
-w /usr/bin/containerd-shim-runc-v1 -p wa -k docker
-w /usr/bin/containerd-shim-runc-v2 -p wa -k docker
-w /usr/bin/runc -p wa -k docker
-w /etc/containerd/config.toml -p wa -k docker

# Audit Docker socket
-w /run/docker.sock -p wa -k docker
-w /run/containerd/containerd.sock -p wa -k docker


# Audit Docker service files (Debian path)
-w /lib/systemd/system/docker.service -p wa -k docker
-w /etc/systemd/system/docker.service -p wa -k docker
-w /etc/systemd/system/multi-user.target.wants/docker.service -p wa -k docker

# Audit the Docker daemon config (Debian paths)
-w /etc/default/docker -p wa -k docker
-w /etc/docker/daemon.json -p wa -k docker
'

echo "sudo systemctl restart auditd
sudo systemctl start auditd
sudo systemctl enable auditd
sudo auditctl -s
"

echo 'sudo vim /etc/docker/daemon.json

{
  "data-root": "/docker",
  "tlsverify": true,
  "tlscacert": "/etc/docker/certs/ca.pem",
  "tlscert": "/etc/docker/certs/server-cert.pem",
  "tlskey": "/etc/docker/certs/server-key.pem" ,
  "userns-remap": "default",
  "live-restore": true,
  "userland-proxy": false
}'
echo "sudo systemctl restart docker.service"


sudo chmod 644 /etc/default/docker
sudo chown root:root /etc/default/docker


echo "Execute: export DOCKER_CONTENT_TRUST=1"
export DOCKER_CONTENT_TRUST=1
docker network create secure_network
