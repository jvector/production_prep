#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

while getopts ":d:f:" opt; do
	case "$opt" in
		f)
			DEFAULTS_FILE=$OPTARG
			;;
		d)
			DEV=$OPTARG
			;;
		?)
			echo "Unknown argument $opt."
			echo "Valid options: -d 1 for dev mode, -f <filename> for non-default"
	esac
done

source container_functions.sh

if [ $DEV = 1 ]; then
	make_mount_directories
	change_permissions_of_mounts
fi

create_docker_network
run_pg_gerrit
run_jenkins & \
run_gerrit
# run_pg_bugzilla
# run_bugzilla
run_redis
run_postfix
run_buildfs
run_internal_repo
run_merged_repo
run_reverse_proxy

echo "Barebone containers started: Now run import.sh if necessary"
