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
	genesis_config
}

function copy_into_local {
	copy_shared
	copy_gnupg
	copy_apt-keys
	copy_shared_jenkins
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
	build_postgres
	build_gerrit
	build_jenkins
}

function start_containers {
	create_docker_network
	start_jenkins
	start_postgres
	start_gerrit
}

setup_config
# Copy into local before mounting
copy_into_local
copy_into_mounts
build_images
start_containers
