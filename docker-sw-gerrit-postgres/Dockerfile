# Copyright Smoothwall Ltd 2015
# https://hub.docker.com/_/postgres/
FROM postgres:9.4
MAINTAINER Smoothwall Ltd <maintenance@smoothwall.net>

RUN localedef -i en_GB -c -f UTF-8 -A /usr/share/locale/locale.alias en_GB.UTF-8
ENV LANG en_GB.utf8

ENV ENTRYPOINT /docker-entrypoint-initdb.d

COPY postgresql.conf ${ENTRYPOINT}/conf/postgresql.conf
COPY config.sh ${ENTRYPOINT}/config.sh

# COPY gerrit_backup.sql ${ENTRYPOINT}/gerrit_backup.sql

# See readme.md for running and diagnostics
