#!/bin/bash
set -x
set -e

# Check if the user gave a valid daemon
SWIFT_DAEMON=${SWIFT_DAEMON,,}
DAEMONS=" proxy object container account config "
echo $DAEMONS | grep $SWIFT_DAEMON

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

if [ "$SWIFT_DAEMON" == "config" ]; then
  cd $HOME/swift/doc; sudo cp -r saio/swift /etc/; cd -
  sudo chown -R root:root /etc/swift
  find /etc/swift/ -name \*.conf | xargs sudo sed -i "s/<your-user-name>/root/"
  chmod 750 /etc/swift/remakerings
  /etc/swift/remakerings
  exit 0
fi

echo "=> Make some loopback devices for storage"
mkfs.xfs /srv/swift-disk 
echo "/srv/swift-disk /mnt/sdb1 xfs loop,noatime,nodiratime,nobarrier,logbufs=8 0 0" >> /etc/fstab
mount /mnt/sdb1
mkdir -p /mnt/sdb1/1 /mnt/sdb1/2 /mnt/sdb1/3 /mnt/sdb1/4
sudo chown root:root /mnt/sdb1/*
for x in {1..4}; do sudo ln -s /mnt/sdb1/$x /srv/$x; done
sudo mkdir -p /srv/1/node/sdb1 /srv/1/node/sdb5 \
              /srv/2/node/sdb2 /srv/2/node/sdb6 \
              /srv/3/node/sdb3 /srv/3/node/sdb7 \
              /srv/4/node/sdb4 /srv/4/node/sdb8 \
              /var/run/swift
sudo chown -R root:root /var/run/swift
for x in {1..4}; do sudo chown -R root:root /srv/$x/; done

echo "=> Setup the configurations"
cp /etc/swift/${SWIFT_DAEMON}-server.template /etc/swift/${SWIFT_DAEMON}-server.conf
sed -i "s/^bind_ip = .*/bind_ip = ${IP}/g" /etc/swift/${SWIFT_DAEMON}-server.conf
sed -i "s/^bind_port = .*/bind_port = ${PORT}/g" /etc/swift/${SWIFT_DAEMON}-server.conf

if [ "$SWIFT_DAEMON" == "proxy" ]; then
  sudo service memcached start
fi

/root/bin/startmain
/bin/bash
