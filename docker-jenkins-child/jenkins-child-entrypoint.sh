#!/bin/bash
# Copyright Smoothwall Ltd 2015

set -e

if [ "$1" = '/jenkins-child-start.sh' ]; then
	echo "Entry script"
fi
exec "$@"
