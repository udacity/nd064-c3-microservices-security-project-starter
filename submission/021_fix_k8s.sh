#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_init.sh"


scp -i ~/.ssh/id_rsa $SUBMISSION/encryption-config.yaml root@1$K8S_IP:/etc/kubernetes/ssl/encryption-config.yaml

ssh root@$K8S_IP '
set -e  # Exit on any error

# Create etcd group and user if they don't exist
getent group etcd || groupadd etcd
id -u etcd &>/dev/null || useradd -r -g etcd -s /sbin/nologin etcd

# Set permissions for etcd data directory
chown -R etcd:etcd /var/lib/etcd

# Restart etcd container
docker ps --filter "name=etcd" --format "{{.Names}}" | grep -q "^etcd$" && docker restart etcd

# Add group and user inside the etcd container
docker exec etcd addgroup --gid 1000 etcd || true
docker exec etcd adduser --uid 999 --ingroup etcd --shell /sbin/nologin --disabled-password etcd || true

# Set permissions for Kubernetes SSL directory
sudo chown -R root:root /etc/kubernetes/ssl
sudo find /etc/kubernetes/ssl -type d -exec chmod 700 {} \;
sudo find /etc/kubernetes/ssl -type f -exec chmod 600 {} \;

# Set permissions for encryption-config.yaml
chmod 600 /etc/kubernetes/ssl/encryption-config.yaml
chown root:root /etc/kubernetes/ssl/encryption-config.yaml
'