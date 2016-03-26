This image has the dependencies for running OpenStack's Swift. It is based on the [Swift All-in-One](http://docs.openstack.org/developer/swift/development_saio.html).

# Quickstart

Start a proxy in a container:
  
```bash
docker run -dt \
  --name swift-node \
  --net=host \
  -e SWIFT_DAEMON=PROXY \
  -e IP=<???> \
  -e PORT=<???> \
  -v /etc/swift:/etc/swift \
  michaelsevilla/swiftdev
```

This is part of a larger deploy framework called [infra](https://github.com/systemslab/infra.git).
