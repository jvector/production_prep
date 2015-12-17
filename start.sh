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

# Sleep here, because the Docker logs ALREADY contain the string's we would
# search for in wait function.
echo "############# $(date ) STARTING CONTAINERS ##############"
start_jenkins
	sleep 60
start_pg_gerrit
	sleep 60
start_redis
start_postfix
start_gerrit
# start_pg_bugzilla
	#sleep 60
#start_bugzilla
start_buildfs
start_internal_repo
start_merged_repo
start_reverse_proxy
