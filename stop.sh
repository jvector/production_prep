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

echo "############# $(date ) STOPPING CONTAINERS ##############"
stop_jenkins
stop_pg_gerrit
stop_redis
stop_gerrit
# stop_pg_bugzilla
# stop_bugzilla
stop_buildfs
stop_internal_repo
