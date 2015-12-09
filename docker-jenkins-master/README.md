## cbuildsystem - docker-jenkins-master

### About this image

This image is used for our Jenkins Master node, it is based from the official jenkins:1.609.3 image. [see more](https://hub.docker.com/_/jenkins/)

We add to it all the required packages/perl modules needed to execute Jenkins jobs.

There are some common files between Jenkins Master and Jenkins Children, these are stored in common_jenkins. There are also some shared files between Jenmaster, Jenchildren and Gerrit in shared. When you run `build.sh` the contents of these get copied into the build contexts of both. If you wish to build this image without using the scripts you will need to make sure the contents of common_jenkins & shared are already copied.

### Build example

```
docker build \
    -t <image-name> \
    --build-arg BUILD_USER_PASSWORD=<build-user-password> \
    docker-jenkins-master
```

###### Notes
You **must** provide build argument **BUILD_USER_PASSWORD**
* **BUILD_USER_PASSWORD** is the password you want the containers build user to have.

### Run example
```
docker run \
        --name <container-name> \
        --privileged \
        -v /some/local/dir:/var/jenkins_home \
        -p 9000:8080 \
        -p 49999:49999 \
        -p 50000:50000 \
        --net=<custom-docker-network> \
        -d <image-name>
```
###### Notes
* **--privileged** flag is essential to allow the container to use hosts devices (i.e. do anything with chroots)
* We volume mount a lot of different things to get our buildsystem to work (none are essential, but /var/jenkins_home is recommended), see `container_functions.sh` for a full example.
* If you **dont** mount a pre populated local dir to /var/jenkins_home any changes made **wont** persist between container restarts.
* Ports - Internal port 8080 is for the WebUI, 49999 we use (set up in config files copied into the /var/jenkins_home mount) for Jenkins SSH and 50000 (set up by the jenkins image) is for communicating with jenchildren nodes.

### Extras
The official jenkins image contains a really nice way to install plugins by simply providing a text file, however because the script is ran at build time, and we volume mount ontop of /var/jenkins_home at run time we no longer use this.
