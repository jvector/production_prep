#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

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
copy_into_home_build_mount

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
echo "############# $(date) build_buildfs ##############"
build_buildfs >> $LOGFILE
build_internal_repo >> $LOGFILE

echo "Build finished, now run ./run.sh"
