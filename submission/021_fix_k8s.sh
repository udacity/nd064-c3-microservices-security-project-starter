scp -i ~/.ssh/id_rsa $SUBMISSION/encryption-config.yaml root@192.168.2.153:/etc/kubernetes/ssl/encryption-config.yaml
ssh root@192.168.2.153 :
groupadd etcd; useradd -r -g etcd -s /sbin/nologin etcd; chown -R etcd:etcd /var/lib/etcd; docker restart etcd
docker exec -it etcd /bin/sh
addgroup --gid 1000 etcd
adduser --uid 999 --ingroup etcd  --shell /sbin/nologin --disabled-password etcd 

sudo chown -R root:root /etc/kubernetes/ssl
sudo chmod -R 600 /etc/kubernetes/ssl
sudo find /etc/kubernetes/ssl \! -user root -o \! -group root

chmod 600 /etc/kubernetes/ssl/encryption-config.yaml
chown root:root /etc/kubernetes/ssl/encryption-config.yaml
