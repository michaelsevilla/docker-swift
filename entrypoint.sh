RUN echo "/srv/swift-disk /mnt/sdb1 xfs loop,noatime,nodiratime,nobarrier,logbufs=8 0 0" >> /etc/fstab

RUN sudo mkdir /mnt/sdb1 && \
    sudo mount /mnt/sdb1 
 
#    sudo mkdir /mnt/sdb1/1 /mnt/sdb1/2 /mnt/sdb1/3 /mnt/sdb1/4 && \
#    sudo chown ${USER}:${USER} /mnt/sdb1/* && \
#    for x in {1..4}; do sudo ln -s /mnt/sdb1/$x /srv/$x; done && \
#    sudo mkdir -p /srv/1/node/sdb1 /srv/1/node/sdb5 \
#                  /srv/2/node/sdb2 /srv/2/node/sdb6 \
#                  /srv/3/node/sdb3 /srv/3/node/sdb7 \
#                  /srv/4/node/sdb4 /srv/4/node/sdb8 \
#                  /var/run/swift && \
#    sudo chown -R ${USER}:${USER} /var/run/swift && \
#    for x in {1..4}; do sudo chown -R ${USER}:${USER} /srv/$x/; done

sudo service memcached start

# 
#!/bin/bash

swift-init all stop
# Remove the following line if you did not set up rsyslog for individual logging:
sudo find /var/log/swift -type f -exec rm -f {} \;
sudo umount /mnt/sdb1
# If you are using a loopback device set SAIO_BLOCK_DEVICE to "/srv/swift-disk"
sudo mkfs.xfs -f ${SAIO_BLOCK_DEVICE:-/dev/sdb1}
sudo mount /mnt/sdb1
sudo mkdir /mnt/sdb1/1 /mnt/sdb1/2 /mnt/sdb1/3 /mnt/sdb1/4
sudo chown ${USER}:${USER} /mnt/sdb1/*
mkdir -p /srv/1/node/sdb1 /srv/1/node/sdb5 \
         /srv/2/node/sdb2 /srv/2/node/sdb6 \
         /srv/3/node/sdb3 /srv/3/node/sdb7 \
         /srv/4/node/sdb4 /srv/4/node/sdb8
sudo rm -f /var/log/debug /var/log/messages /var/log/rsyncd.log /var/log/syslog
find /var/cache/swift* -type f -name *.recon -exec rm -f {} \;
if [ "`type -t systemctl`" == "file" ]; then
    sudo systemctl restart rsyslog
    sudo systemctl restart memcached
else
    sudo service rsyslog restart
    sudo service memcached restart
fi

sed -i "/find \/var\/log\/swift/d" $HOME/bin/resetswift

remakerings
startmain
