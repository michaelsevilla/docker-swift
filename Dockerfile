FROM tutum/ubuntu:trusty

MAINTAINER Michael Sevilla <mikesevilla3@gmail.com>

# install deps
RUN echo "===> Installing swift stuff..." 
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo "deb http://cz.archive.ubuntu.com/ubuntu trusty-backports main universe" >> /etc/apt/sources.list && \
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
      liberasurecode-dev \
      python-setuptools \
      python-coverage \
      python-dev \
      python-nose \
      python-xattr \
      python-eventlet \
      python-greenlet \
      python-pastedeploy \
      python-netifaces \
      python-pip \
      python-dnspython \
      python-mock && \
   pip install -U pip wheel setuptools && \
   apt-get remove -y python-pip && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "===> Setup loopback device..." && \
    truncate -s 1GB /srv/swift-disk

RUN echo "===> Getting the code..." && \
    cd /root; git clone https://github.com/openstack/python-swiftclient.git && \
    cd /root/python-swiftclient; sudo python setup.py develop; cd - && \
    cd /root; git clone https://github.com/openstack/swift.git && \
    cd /root/swift; sudo pip install -r requirements.txt; sudo python setup.py develop; cd - && \
    cd /root/swift; sudo pip install -r test-requirements.txt 

# tasks in the entrypoint: finish setting up loopback device/partition, memcached, configure
# skipped tasks: setting up rclocal, rsync

ADD entrypoint.sh /entrypoint.sh
RUN chmod 750 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
