This image has the dependencies for running OpenStack's Swift. For more information,
see the [Swift All-in-One](http://docs.openstack.org/developer/swift/development_saio.html).

# Quickstart

  1. Start a container:
  
    ```bash
    docker run -d \
      --name remote0 \
      --net=host \
      --capability=CAP_MKNOD \
      michaelsevilla/swiftdev
    ```
  
  2. Start the entrypoint:
  
    ```bash
    docker exec swift /entrypoint.sh
    ```

# Running experiments
