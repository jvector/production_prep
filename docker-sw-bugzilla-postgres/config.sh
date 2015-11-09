#!/bin/bash
# Copyright Smoothwall Ltd 2015

CONFIG_DIR=/var/lib/postgresql/data
SERVER_CONFIG=${CONFIG_DIR}/postgresql.conf
ENTRYPOINT=/docker-entrypoint-initdb.d/conf

# Smoothwall modifications to PostgreSQL
sed -i '/^#include_dir.*/s/^#//' ${SERVER_CONFIG}
mkdir ${CONFIG_DIR}/conf.d
cp ${ENTRYPOINT}/bugzilla-postgresql.conf ${CONFIG_DIR}/conf.d/bugzilla-postgresql.conf
