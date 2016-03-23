#!/bin/bash
set -x
set -e
echo "=> Using a loopback device for storage"
mkfs.xfs /srv/swift-disk 
echo "/srv/swift-disk /mnt/sdb1 xfs loop,noatime,nodiratime,nobarrier,logbufs=8 0 0" >> /etc/fstab
mkdir -p /mnt/sdb1/1 /mnt/sdb1/2 /mnt/sdb1/3 /mnt/sdb1/4 && \
sudo chown root:root /mnt/sdb1/* && \
for x in {1..4}; do sudo ln -s /mnt/sdb1/$x /srv/$x; done && \
sudo mkdir -p /srv/1/node/sdb1 /srv/1/node/sdb5 \
              /srv/2/node/sdb2 /srv/2/node/sdb6 \
              /srv/3/node/sdb3 /srv/3/node/sdb7 \
              /srv/4/node/sdb4 /srv/4/node/sdb8 \
              /var/run/swift && \
sudo chown -R root:root /var/run/swift && \
for x in {1..4}; do sudo chown -R root:root /srv/$x/; done

echo
echo "=> Starting memcached"
sudo service memcached start

echo
echo "=> Configuring each node"
cd $HOME/swift/doc; sudo cp -r saio/swift /etc/; cd -
sudo chown -R root:root /etc/swift
find /etc/swift/ -name \*.conf | xargs sudo sed -i "s/<your-user-name>/root/"

echo
echo "=> Setting up scripts for running Swift"
mkdir -p $HOME/bin
cd $HOME/swift/doc; cp saio/bin/* $HOME/bin; cd -
chmod +x $HOME/bin/*
echo "export SAIO_BLOCK_DEVICE=/srv/swift-disk" >> $HOME/.bashrc
sed -i "/find \/var\/log\/swift/d" $HOME/bin/resetswift
cp $HOME/swift/test/sample.conf /etc/swift/test.conf
echo "export SWIFT_TEST_CONFIG_FILE=/etc/swift/test.conf" >> $HOME/.bashrc
echo "export PATH=${PATH}:$HOME/bin" >> $HOME/.bashrc
. $HOME/.bashrc

echo "=> Reinstalling Swift"
cd /root/python-swiftclient; sudo python setup.py develop; cd - 
cd /root/swift; sudo pip install -r requirements.txt; sudo python setup.py develop; cd -
/bin/bash -c "/root/bin/remakerings"
/bin/bash -c "/root/bin/startmain"
/bin/bash
