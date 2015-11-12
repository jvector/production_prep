# Copyright Smoothwall Ltd 2015
# Draws from https://github.com/dklawren/docker-bugzilla &
# https://github.com/gameldar/bugzilla
FROM debian:jessie
MAINTAINER Smoothwall Ltd <maintenance@smoothwall.net>

# Defaults to bugzilla unless defined @ buildtime
ARG BUGZILLA_HOSTNAME=bugzilla
ARG BUGZILLA_ROOT

ENV BUGZILLA_ROOT ${BUGZILLA_ROOT:-/var/www/$BUGZILLA_HOSTNAME}

# Accept build time arguments
# We don't carry these into the environment, set them at build
ARG ADMIN_EMAIL
ARG ADMIN_PASSWORD

ARG DB_DRIVER
ARG DB_HOST
ARG DB_PORT
ARG DB_NAME
ARG DB_USER
ARG DB_PASS

ARG WEB_SERVER_GROUP

# Set env's to build time arguments or defaults if not supplied
# Can also be changed at run time using -e DB_DRIVER=<new_value>
ENV ADMIN_EMAIL=${ADMIN_EMAIL:-admin@bugzilla.com} \
	ADMIN_PASSWORD=${ADMIN_PASSWORD:-123456} \
	DB_DRIVER=${DB_DRIVER:-pg} \
	DB_HOST=${DB_HOST:-pg-bugzilla} \
	DB_PORT=${DB_PORT:-0} \
	DB_NAME=${DB_NAME:-bugs} \
	DB_USER=${DB_USER:-bugs} \
	DB_PASS=${DB_PASS} \
	WEB_SERVER_GROUP=${WEB_SERVER_GROUP:-www-data}

# Install dependencies
RUN apt-get update && apt-get -y -q install \
	wget \
	postgresql-client-9.4 \
	apache2 \
	libdatetime-perl \
	libdatetime-format-builder-perl \
	libwww-bugzilla-perl \
	libdbd-pg-perl \
	libtemplate-perl \
	libemail-sender-perl \
	libemail-mime-perl \
	libmath-random-isaac-perl \
	libfile-slurp-perl \
	libjson-perl

# Install bugzilla
RUN wget http://ftp.mozilla.org/pub/mozilla.org/webtools/bugzilla-5.0.1.tar.gz \
	&& mkdir -p $BUGZILLA_ROOT \
	&& tar -xzf bugzilla-5.0.1.tar.gz -C $BUGZILLA_ROOT --strip-components=1 \
	&& rm bugzilla-5.0.1.tar.gz

# All *.sh placed in this directory will be ran
RUN mkdir /docker-entrypoint-init.d

COPY docker-entrypoint.sh /
COPY bugzilla-start.sh /
COPY bugzilla-pg-password.sh /
COPY apache_setup.sh /docker-entrypoint-init.d

# Copy in script to add Smoothwall-isms to specific Templates
COPY modify_templates.sh /docker-entrypoint-init.d

# DEV ONLY REMOVE BEFORE releases
RUN apt-get update && apt-get install -y vim && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "/bugzilla-start.sh" ]
