# Copyright Smoothwall Ltd 2015
# https://hub.docker.com/r/openfrontier/gerrit/
FROM openfrontier/gerrit:latest
MAINTAINER Smoothwall Ltd <maintenance@smoothwall.net>

# We've already got Gerrit ready to roll, we just need to futz with it a bit.
ENV ENTRYPOINT /docker-entrypoint-init.d

ENV GERRIT_INIT_ARGS \
  --install-plugin=commit-message-length-validator \
  --install-plugin=download-commands \
  --install-plugin=replication \
  --install-plugin=reviewnotes \
  --install-plugin=singleusergroup

# Copy the ssh keys previously generated into our DockerFile location,
# as made by the initial distribute_keys step of the mkbuildsystem script

RUN apt-get update && apt-get -y -q install \
    sudo \
    libredis-perl \
    openssh-server \
    lighttpd \
    ntpdate \
    gitweb \
    reprepro \
    postgresql-client-9.4 \
    perl libwww-bugzilla-perl libipc-run-perl libjson-perl \
    && rm -rf /var/lib/apt/lists/*

# Copy
    # Shared build
# buildsystem - Common files are copied in via mkbuildsystem script. If
# you want to build this manually, and the files don't exist it will error.
# Circumvent this by copying manually from one level up, or run copy_shared in
# container_functions.sh
COPY shared /usr/src/
    # SSH
COPY .ssh/ /var/gerrit/.ssh
    # Scripts
COPY scripts/ /scripts
COPY config.sh ${ENTRYPOINT}/config.sh
    # SQL
#COPY jenkins_user.sql /jenkins_user.sql
    # Password for PG, stored in private Git
COPY pg-gerrit-password.sh /pg-gerrit-password.sh
    # Gerrit start replace
COPY gerrit-start.sh /gerrit-start.sh
    # Global repo signing keys
COPY apt-keys /var/lib/sbuild/apt-keys
    # Ssh config for gerrit2
COPY ssh_config /var/gerrit/.ssh/config
	# Extra's
COPY sudo.txt /sudo.txt

# Build user
# Create build user, let it use /usr/src/. Allow jenkins also
RUN useradd -u 1001 build
RUN echo "build:Sm00th" | sudo chpasswd

RUN chown build:build /usr/src/ -Rf

# Put patch-configuration in the right place
RUN mv /usr/src/patch-configuration.json /etc/patch-configuration.json

# Run config scripts
    # Install aptly
RUN /usr/src/aptly_setup.sh
# /Scripts
    # Start lighttpd
RUN /scripts/lighttpd_setup.sh
    # Setup gitweb
RUN /scripts/gitweb_setup.sh

COPY GerritSiteHeader.html /etc_copy/GerritSiteHeader.html

# DEV ONLY REMOVE BEFORE releases
RUN apt-get update && apt-get install -y vim && rm -rf /var/lib/apt/lists/*
