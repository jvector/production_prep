#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

source container_functions.sh

create_docker_network
start_jenkins
start_pg_gerrit
start_redis
start_gerrit
# start_pg_bugzilla
# start_bugzilla
start_buildfs
start_internal_repo

echo "Barebone containers started: Now run import.sh if necessary"
