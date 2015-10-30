# To build this into an image:
docker build -t gerrit-postgresql .

# See readme.md for running and diagnostics

# https://wiki.debian.org/PostgreSql
# Run this container in the background
docker run -d --rm --name gerrit_pg \
  -p 5432:5432 \
  -v /var/lib/containers/data/docker-sw-gerrit-postgres/log:/var/log/postgres \
  -v /var/lib/containers/data/docker-sw-gerrit-postgres/lib:/var/lib/postgres \
  gerrit-postgresql

# We don't bind mount the configuration, otherwise you can hack the config without
# rebuilding the image.
#  -v /var/lib/containers/data/docker-sw-gerrit-postgres/etc:/etc/postgres

# Test the running postgres container:
sudo apt-get install postgres-client-9.4
psql -h localhost -p 5432 -U gerrit -l # lists databases

# Specific debug:

# Run the container in the foreground:
docker run --rm -P --name pg_test gerrit-postgresql
# -P   map all EXPOSEd ports to random host ports
# Then do
# docker ps
# To show the exposed ports

# Production:
# docker run -d --name <name>
#  -d   daemonize / background
#  -v   bind mount
#  -p   port mapping

# Diagnostics:
# docker run -i -t <image> /bin/bash
#  -i, --interactive=false    Keep STDIN open even if not attached
#  -t, --tty=false            Allocate a pseudo-TTY
#  -v, --volume=[]            Bind mount a volume (e.g., from the host: -v /host:/container, from Docker: -v /container)
