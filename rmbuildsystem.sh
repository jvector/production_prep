#!/bin/bash
# Copyright Smoothwall Ltd 2015
while getopts ":d:f:" opt; do
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

function stop_containers {
	echo "############# $(date )STOPPING CONTAINERS ##############"
	rm_jenkins
	rm_pg_gerrit
	rm_gerrit
	rm_redis
	rm_pg_bugzilla
	rm_bugzilla
	rm_buildfs
	rm_internal_repo
	rm_docker_network
}

function clear_mounted_files {
	echo "############# $(date )CLEARING MOUNTED FILES ##############"
	rm_from_repo
	rm_from_shared_src
	rm_from_shared_dev-metadata
	rm_from_gerrit_gits
	rm_from_home_build_mount
	rm_from_mnt_build
}

function rm_local_copies {
	echo "############# $(date )CLEANING UP LOCAL ENVIRONMENT ##############"
	rm_shared_copies
	rm_gnupg
	rm_apt-keys
	rm_common_jenkins
	rm_shared_bugzilla
	rm_shared_db_conf
}

stop_containers
clear_mounted_files
rm_local_copies
