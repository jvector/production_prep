## cbuildsystem - docker-sw-bugzilla-postgres

### About this image

It is based from the official Postgres image - [see more](https://hub.docker.com/_/postgres/).

We run two postgres containers, one for gerrit and one for bugzilla. They share common configuration files between them, stored in shared_db_conf. 

When you run `build.sh` the contents of shared_db_conf get copied into the build contexts of gerrit-postgres and bugzilla-postgres. This does save us committing duplicate code twice, but it means if you wish to build this image without using the scripts you will need to make sure the contents of shared_db_conf are already copied.

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
	-p 5433:5432 \
	-v /some/local/dir:/var/lib/postgresql/data \
	-e POSTGRES_USER=bugs \
	-e POSTGRES_PASSWORD=$PGPASSWORD \
	-e POSTGRES_DB=bugs \
	--net=<custom-docker-network> \
	-d <image-name>
```
###### Notes
* Above we map the <host-port>:<container-port>. The host-post can be any free port, but the container-port should be the postgres default 5432.
* Official postgres image is really well written, it provides the ability to supply a selection of environment variables to automatically set up state. [Documentation](https://hub.docker.com/_/postgres/)

### Extras
This image includes a helper script to make importing db_dump's easier. The script expects the database dump to be saved to /var/lib/postgresql/data/bugs_backup.sql. To put the file there you will need to volume mount /some/local/dir to /var/lib/postgresql/data within the container using -v at runtime. e.g.
`-v /some/local/dir:/var/lib/postgresql/data \`

The script is copied into the container @ `/dbimport.sh`, and can be used via a docker exec call on the container host. e.g. `docker exec -d <container-name> /dbimport.sh`
