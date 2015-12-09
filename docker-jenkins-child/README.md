## cbuildsystem - docker-jenkins-child

### About this image

This image is used for our Jenkins child nodes, it is based from the official debian:jessie image. 

We add to it all the required packages/perl modules needed to execute Jenkins jobs.

There are some common files between Jenkins Master and Jenkins Children, these are stored in common_jenkins. There are also some shared files between Jenmaster, Jenchildren and Gerrit in shared. When you run `build.sh` the contents of these get copied into the build contexts of both. If you wish to build this image without using the scripts you will need to make sure the contents of common_jenkins & shared are already copied.

### Build example

```
docker build \
    -t <image-name><child-sequence> \
    --build-arg BUILD_USER_PASSWORD=<build-user-password> \
	--build-arg CHILD_SEQ=<child-sequence> \
    /path/to/Dockerfile \
```

###### Notes
You **must** provide build arguments - **BUILD_USER_PASSWORD** & **CHILD_SEQ**.
* **BUILD_USER_PASSWORD** is the password you want the containers build user to have.
* **CHILD_SEQ** is used to determine which etc_ssh(1|2) to copy into the container as /etc/ssh. For now this just has two avaliable to choose from at build.

### Run example
```
docker run \
    --name=<container-name> \
    --privileged \
    -v /some/local/dir:/dir/inside/container \
    --net=<custom-docker-network> \
	-d <image-name>
```
###### Notes
* **--privileged** flag is essential to allow the container to use hosts devices (i.e. do anything with chroots)
* We volume mount a lot of different things to get our buildsystem to work (but none are essential for the container to start), see `container_functions.sh` for a full example.
* We don't expose any ports, because the container is only used by jenmaster-container and not accessed by the user at all.

### Extras
