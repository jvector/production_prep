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

generate_keys
genesis_config
copy_shared
copy_into_repo
copy_gnupg
build_postgres
build_gerrit
build_jenkins

start_jenkins
start_postgres
start_gerrit