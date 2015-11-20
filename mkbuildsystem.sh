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

if [ "$DEV" = 1 ]; then
	echo "Dev mode activated"
fi

function setup_config {
	generate_keys
	patch_buildsystem_references
	fix_change_merged_for_new_gerrit
	patch_gerrit_site_header
}

function copy_into_local {
	copy_shared
	copy_gnupg
	copy_apt-keys
	copy_shared_jenkins
	copy_shared_bugzilla
	copy_shared_db_conf
}

function copy_into_mounts {
	copy_into_repo
	copy_into_shared_src
	copy_into_shared_dev-metadata
	copy_into_gerrit_gits
	copy_into_home_build_mount
	copy_into_mnt_build
}

function build_images {
	build_pg_gerrit
	build_gerrit
	build_jenkins
	build_pg_bugzilla
	build_bugzilla
	build_buildfs
}

function start_containers {
	create_docker_network
	start_jenkins
	start_pg_gerrit
	start_redis
	start_gerrit
	start_pg_bugzilla
	start_bugzilla
	start_buildfs
}

setup_config
# Copy into local before mounting
copy_into_local
copy_into_mounts
build_images
start_containers
