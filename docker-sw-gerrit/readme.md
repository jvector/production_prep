# Copyright Smoothwall Ltd 2015
# To build this into an image:
docker build -t sw/gerrit .

# https://wiki.debian.org/PostgreSql
# Run this container in the background
docker run -d --name gerrit \
  -p 8080:8080 \
  sw/gerrit

# Specific debug:

# Run the container in the foreground:
docker run --rm -P --name gerrit sw/gerrit
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
