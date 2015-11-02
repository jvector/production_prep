#!/bin/bash
# Copyright Smoothwall Ltd 2015

set -e

chown -R build:build /home/build

if [ "$1" = '/jenkins-child-start.sh' ]; then
	echo "Entry script"
fi
exec "$@"
