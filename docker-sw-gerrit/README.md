## cbuildsystem - docker-sw-gerrit

### About this image

It is based from [openfrontier/docker-gerrit](https://github.com/openfrontier/docker-gerrit).

Our custom configuration to this image is mostly in the form of putting our files in the right place or installing packages needed by the buildsystem, the gerrit installation is largely left untouched.

We do however define custom config in config.sh which is copied into the correct place and auto-ran by the container on start up, but this is mostly changing `/review_site/etc/gerrit.config`

There are some shared files between Jenmaster, Jenchildren and Gerrit in shared. When you run `build.sh` the contents of these get copied into the build contexts of both. If you wish to build this image without using the scripts you will need to make sure the contents of shared are already copied.

### Build example

```
docker build \
    -t <image-name> \
    --build-arg BUILD_USER_PASSWORD=<build-user-password> \
    /path/to/Dockerfile \
```

###### Notes
You **must** provide build argument **BUILD_USER_PASSWORD**
* **BUILD_USER_PASSWORD** is the password you want the containers build user to have.

### Run example
```
 docker run \
    --name <container-name> \
    --privileged \
    -v /local/dir:/var/gerrit/review_site \
    -v /local/dir:/usr/src/gerrit \
    -p 29418:29418 \
    -p 8080:8080 \
	-p 8081:80 \
    -p 222:22 \
    -e WEBURL=<url-for-gerrit> \
    -e DATABASE_HOSTNAME=<hostname-for-db> \
    -e REDIS_HOSTNAME=<hostname-for-redis> \
    -e HOST=${HOST} \
    -e SMTP_SERVER=<hostname-for-postfix> \
    -e SMTP_USER=<postfix-user> \
    -e SMTP_PASS=<postfix-password> \
    -e SMTP_SERVER_PORT=25 \
    --net=<custom-docker-network> \
    -d <image-name>
```
###### Notes
* **--privileged** flag is essential to allow the container to use hosts devices (i.e. do anything with chroots)
* We volume mount a lot of different things to get our buildsystem to work (none are essential, but /var/gerrit/review_site and /usr/src/gerrit are recommended), see `container_functions.sh` for a full example.
* If you **dont** mount these directories changes made to Gerrit / Work committed to projects **wont** persist between container restarts.
* Ports - Internal port 8080 is for the WebUI, 29418 is for the Gerrit ssh commands, 80 is for Gitweb WebUI and 22 is for the sshd to allow you to ssh into this container.
* A fair few environment variables need to be passed at run time to this image to ensure that small features, redis, email sending etc are working. See below for more information.

### Extras
This container has a running sshd process, meaning you can do `ssh -p 222 build@<host>` directly without having to ssh onto host and then docker exec into the container.

Any scripts copied into /docker-entrypoint-init.d (inside the container) will be automatically ran at start up.

### Extra Containers
This container uses two very lightweight containers for some of its functionality, one running Redis (for parts of the buildsystem) and another running Postfix (for Gerrit to send mail).

Mini readme's for each below.

#### Redis
We use the official [redis image](https://hub.docker.com/_/redis/) as it comes, and give it almost no configuration. As such it does not have a build step, only a run.

##### Run example
```
docker run \
    --name <container-name> \
    -p 6379:6379 \
    --net=<custom-docker-network> \
    -d redis:3.0.5
```

#### Postfix
To enable gerrit to send mails, we need to run Postfix, for this we use the [catatnight/postfix](https://hub.docker.com/r/catatnight/postfix/) image as it comes, passing the little configuration it needs at run time. As such it does not have a build step, only a run.

#### Run example
```
docker run \
    --name <container-name> \
    -p 250:25 \
    -e maildomain=<mail-domain> \
    -e smtp_user=<user>:<password> \
    --net=<custom-docker-network> \
    -d catatnight/postfix
```

##### Notes
* Make sure the configuration entered here matches what you provide to Gerrit, or postfix will be misconfigured and gerrit wont send emails.
