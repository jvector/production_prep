#!/bin/bash
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

LOGFILE=build.log

if [ "$DEV" = 1 ]; then
	echo "Dev mode activated"
fi

function setup_config {
	echo "############# $(date )SET UP CONFIG ##############"
	generate_keys
	patch_buildsystem_references
	fix_change_merged_for_new_gerrit
	patch_gerrit_site_header
}

function copy_into_local {
	echo "############# $(date) COPY INTO LOCAL ##############"
	copy_shared
	copy_gnupg
	copy_apt-keys
	copy_common_jenkins
	copy_shared_bugzilla
	copy_shared_db_conf
}

function copy_into_mounts {
	echo "############# $(date) COPY INTO MOUNTS ##############"
	copy_into_repo
	copy_into_shared_src
	copy_into_shared_dev-metadata
	copy_into_gerrit_gits
	copy_into_home_build_mount
	copy_into_mnt_build
}

function build_images {
	echo "############# $(date) build_pg_gerrit ##############"
	build_pg_gerrit >> $LOGFILE
	echo "############# $(date) build_gerrit ##############"
	build_gerrit  >> $LOGFILE
	echo "############# $(date) build_jenkins ##############"
	build_jenkins  >> $LOGFILE
	echo "############# $(date) build_pg_bugzilla ##############"
	build_pg_bugzilla >> $LOGFILE
	echo "############# $(date) build_bugzilla ##############"
	build_bugzilla >> $LOGFILE
	echo "############# $(date) build_buildfs ##############"
	build_buildfs >> $LOGFILE
	build_internal_repo >> $LOGFILE
}

function start_containers {
	echo "############# $(date) STARTING CONTAINERS ##############"
	create_docker_network
	start_jenkins
	start_pg_gerrit
	start_redis
	start_gerrit
	start_pg_bugzilla
	start_bugzilla
	start_buildfs
	start_internal_repo
}

setup_config
# Copy into local before mounting
copy_into_local
copy_into_mounts
build_images
start_containers
