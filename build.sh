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

LOGFILE=build.log

# Config
distribute_keys

# Move to local contexts
copy_shared
copy_gnupg
copy_apt-keys
copy_common_jenkins
copy_shared_db_conf

# For the keys to work
#copy_into_home_build_mount

# Build the images
echo "############# $(date) build_pg_gerrit ##############"
build_pg_gerrit >> $LOGFILE
echo "############# $(date) build_gerrit ##############"
build_gerrit  >> $LOGFILE
echo "############# $(date) build_jenkins ##############"
build_jenkins  >> $LOGFILE
#echo "############# $(date) build_pg_bugzilla ##############"
# build_pg_bugzilla >> $LOGFILE
# echo "############# $(date) build_bugzilla ##############"
# build_bugzilla >> $LOGFILE
echo "############# $(date) building extras ##############"
build_buildfs >> $LOGFILE
build_internal_repo >> $LOGFILE
build_reverse_proxy >> $LOGFILE

echo "Build finished, now run ./run.sh"
