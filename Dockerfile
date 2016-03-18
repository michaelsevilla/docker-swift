FROM tutum/ubuntu:trusty

MAINTAINER Michael Sevilla <mikesevilla3@gmail.com>

# install deps
RUN echo "===> Installing swift stuff..." 
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y \
      curl \
      gcc \
      memcached \
      rsync \
      sqlite3 \
      xfsprogs \
      git-core \
      libffi-dev \
      python-setuptools \
      python-coverage \
      python-dev python-nose \
      python-xattr \
      python-eventlet \
      python-greenlet \
      python-pastedeploy \
      python-netifaces \
      python-pip \
      python-dnspython \
      python-mock && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "===> Setup loopback device..." && \
    truncate -s 1GB /srv/swift-disk && \
    mkfs.xfs /srv/swift-disk 
# finish setting up loopback device or partition in the entrypoint
# skip setting up rclocal

RUN echo "===> Getting the code..." && \
     cd /root; git clone https://github.com/openstack/python-swiftclient.git && \
     cd /root/python-swiftclient; sudo python setup.py develop; cd - && \
     cd /root; git clone https://github.com/openstack/swift.git && \
     cd /root/swift; sudo pip install -r requirements.txt; sudo python setup.py develop; cd - && \
     cd /root/swift; sudo pip install -r test-requirements.txt 

# skip setting up rsync
# setup memcached in entrypoint

RUN echo "===> Configuring each node..." && \
    cd /root/swift/doc; sudo cp -r saio/swift /etc/swift; cd - && \
    sudo chown -R root:root /etc/swift && \
    find /etc/swift/ -name \*.conf | xargs sudo sed -i "s/<your-user-name>/root/"

RUN echo "===> Setting up scripts for running Swift" && \
    mkdir -p root/bin && \
    cd /root/swift/doc; cp saio/bin/* /root/bin; cd - && \
    chmod +x /root/bin/* && \
    echo "export SAIO_BLOCK_DEVICE=/srv/swift-disk" >> /root/.bashrc && \
    cp /root/swift/test/sample.conf /etc/swift/test.conf && \
    echo "export SWIFT_TEST_CONFIG_FILE=/etc/swift/test.conf" >> $HOME/.bashrc && \
    echo "export PATH=${PATH}:$HOME/bin" >> $HOME/.bashrc

# edit the resetswift code in the entrypoint

#ADD entrypoint.sh /entrypoint.sh
#RUN chmod 750 /entrypoint.sh
#ENTRYPOINT['/entrypoint.sh']
