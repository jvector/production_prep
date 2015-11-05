#!/bin/bash
# Copyright Smoothwall Ltd 2015

set -e

# Here we chown files which are located on Host to user build
# It is a rather messy way to do this, but solves needing a user
# build on host.
chown -R build:build /home/build
chown -R build:build /usr/src
chown -R build:build /mnt/build

if [ "$1" = '/jenkins-child-start.sh' ]; then
	echo "Entry script"
fi
exec "$@"
