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

rm_jenkins
rm_postgres
rm_gerrit
rm_shared_buildsystem_copies
rm_from_repo
rm_from_home_build_mount
rm_gnupg
rm_apt-keys
rm_shared_jenkins
