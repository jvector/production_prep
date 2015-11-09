# Copyright Smoothwall Ltd 2015
# https://hub.docker.com/_/postgres/
FROM postgres:9.4
MAINTAINER Smoothwall Ltd <maintenance@smoothwall.net>

RUN localedef -i en_GB -c -f UTF-8 -A /usr/share/locale/locale.alias en_GB.UTF-8
ENV LANG en_GB.utf8

# Override default with our slightly modified version
COPY docker-entrypoint.sh /docker-entrypoint.sh

# From sbuild-secrets
COPY bugzilla-secret-password.sh /

ENV ENTRYPOINT /docker-entrypoint-initdb.d

COPY bugzilla-postgresql.conf ${ENTRYPOINT}/conf/bugzilla-postgresql.conf
COPY config.sh ${ENTRYPOINT}/config.sh

COPY bugs_backup.sql ${ENTRYPOINT}/bugs_backup.sql
