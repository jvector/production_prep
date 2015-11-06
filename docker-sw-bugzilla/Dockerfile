# Copyright Smoothwall Ltd 2015
# Draws from https://github.com/dklawren/docker-bugzilla &
# https://github.com/gameldar/bugzilla
FROM debian:jessie
MAINTAINER Smoothwall Ltd <maintenance@smoothwall.net>

# Defaults to bugzilla.container.smoothwall.com unless defined @ buildtime
ARG BUGZILLA_USER
ARG BUGZILLA_HOSTNAME=bugzilla
ARG BUGZILLA_ROOT

ENV BUGZILLA_USER ${BUGZILLA_USER:-bugzilla}
ENV BUGZILLA_ROOT ${BUGZILLA_ROOT:-/var/www/$BUGZILLA_HOSTNAME}

#RUN useradd -m -d "$BUGZILLA_ROOT" -U $BUGZILLA_USER

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
	ADMIN_PASSWORD=${ADMIN_PASSWORD:-1234} \
	DB_DRIVER=${DB_DRIVER:-pg} \
	DB_HOST=${DB_HOST:-pg-gerrit} \
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
	# && chown -Rf www-data:www-data $BUGZILLA_ROOT

# All *.sh placed in this directory will be ran
RUN mkdir /docker-entrypoint-init.d

COPY docker-entrypoint.sh /
COPY bugzilla-start.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "/bugzilla-start.sh" ]
#COPY localconfig $BUGZILLA_ROOT/localconfig
