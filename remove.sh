#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

while getopts ":f:" opt; do
	case "$opt" in
		f)
			DEFAULTS_FILE=$OPTARG
			;;
		?)
			echo "Unknown argument $opt."
			echo "Valid options: -f <filename> for non-default"
	esac
done

source container_functions.sh

echo "############# $(date ) REMOVING CONTAINERS ##############"
rm_jenkins
rm_pg_gerrit
rm_redis
rm_gerrit
# rm_pg_bugzilla
# rm_bugzilla
rm_buildfs
rm_internal_repo

rm_docker_network

echo "############# $(date ) CLEANING UP LOCAL ENVIRONMENT ##############"
rm_shared_copies
rm_gnupg
rm_apt-keys
rm_shared_bugzilla
rm_shared_db_conf

# For now, remove needs to delete local build users junk also...
# Remove when mounted sufficiently
#rm_from_home_build_mount
