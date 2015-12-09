## cbuildsystem - docker-sw-reverse-proxy

### About this image

This image is essentially the official [nginx image](https://hub.docker.com/_/nginx/) with our prewritten default.conf copied in.

We could just use their image and mount in the config file via `-v` at runtime but the configuration is static and by creating a derived image it is easier for us to add more if required later on.

### Build example

```
docker build \
    -t <image-name> \
    /path/to/Dockerfile
```

###### Notes
* None

### Run example
```
docker run \
    --name <container-name> \
    -p 80:80 \
    --net=<custom-docker-network> \
    -d <image-name>
```
###### Notes
* At start up time, if nginx is unable to resolve a host it is expecting in its config (for example, if it can't see gerrit on the docker network because the container has stopped) then this container **will not start**.

### Extras
The majority of the configuration for this reverse proxy is static in default.conf. To add extras, add them to that file and rebuild.
