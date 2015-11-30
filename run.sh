#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

source container_functions.sh

make_mount_directories
change_permissions_of_mounts

create_docker_network
run_jenkins
run_pg_gerrit
run_redis
run_gerrit
# run_pg_bugzilla
# run_bugzilla
run_buildfs
run_internal_repo

echo "Barebone containers started: Now run import.sh if necessary"
