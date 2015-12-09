## cbuildsystem - docker-sw-bugzilla

### About this image

This image is used for Bugzilla, it is our image but draws inspiration from [dklawren/docker-bugzilla](https://github.com/dklawren/docker-bugzilla) and [gameldar/bugzilla](https://github.com/gameldar/bugzilla).

It is not currently on Dockerhub / avaliable publicly, but there is a version which has been appropriately generic/documented in effort for it to be possible to upload on Dockerhub/Github. Our version does differ slightly, but the aim would be to turn this image into a derived version of smoothwall/bugzilla.

*It can be seen at /global/users/jonathan.barron/docker-bugzilla*

It is based from the official debian:jessie image with required packages/perl modules install to fulfil the minimum requirements required for Bugzilla.

It relies on an existing Postgres Database (be it container or on host) that it can connect to and internally runs Apache2 to serve the Bugzilla cgi's.

The image has been created to provide lots of customization options without having to create a derived image, there are a lot of build args / environment variables which can either be set at build or run time. *See below for examples*

This image and bugzilla-postgres share a password file, which is located in cbuild-secrets:shared_bugzilla/bugzilla-pg-password.sh.

During the `build.sh` this file gets put into the build context for the images, if you want to build this image without using the scripts make sure the file is copied in beforehand.

### Build example

```
docker build \
	-t <image-name> \
	--build-arg DB_USER=bugs \
	/path/to/Dockerfile
```

###### Notes
* The following list of Build arguments are available. (Only DB_PASS is essential, the rest all have defaults built into the Dockerfile if not set)

| Name | Description | Default |
|------|-------------|---------|
| **BUGZILLA_VERSION*** | Specify a Bugzilla version | 4.2.11|
| **BUGZILLA_HOSTNAME** | Used to determine BUGZILLA_ROOT | bugzilla |
| **BUGZILLA_ROOT** | The root directory for the Bugzilla installation | /var/www/$BUGZILLA_HOST |
| **ADMIN_EMAIL** | Email address for the Bugzilla Admin | admin@bugzilla.com |
| **ADMIN_PASSWORD*** | Password for the Bugzilla Admin | 123456 |
| **DB_DRIVER** | Database driver to use | pg |
| **DB_HOST** | Hostname for the Database/Database container | pg-bugzilla |
| **DB_PORT*** | Port used to access the Database | 0 |
| **DB_NAME** | Name of the Database to access | bugs |
| **DB_USER** | Username to use when accessing the Database | bugs |
| **DB_PASS** | Password for the DB_USER (6 chars+) | **No default** |
| **WEB_SERVER_GROUP** | Web server group to run as | www-data |

* Set these using `--build-arg ADMIN_EMAIL=foo@bar.net`
### Run example
```
docker run \
    --name <container-name> \
    -p 8888:80 \
    -e DB_HOST=<hostname-of-db> \
    --net=<custom-docker-network> \
    -d <image-name>
```
###### Notes
* The list of build arguments above apart from **BUGZILLA_VERSION** and **BUGZILLA_HOSTNAME** can also be set at docker run time, using the `-e` flag. e.g.
`-e ADMIN_EMAIL=foo@bar.net`. Try not to set the same variable twice (once at build, once at run) because [docker does fun things with it](http://docs.docker.com/engine/reference/builder/#arg).
* The internal Apache2 listens on port 80, this can be mapped to any host port you like.

### Extras
Drawing from the Postgres official image, if you want to run extra scripts at startup just drop them via the Dockerfile into /docker-entrypoint-init.d and they will get ran automatically on start up. This means it's very easy to add any functionality you like in a very simple derived image.
