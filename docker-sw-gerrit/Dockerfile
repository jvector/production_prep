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
# as made by the initial generate_keys step of the mkbuildsystem script

RUN apt-get update && apt-get -y -q install \
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
COPY shared_buildsystem /usr/src/
    # SSH
COPY .ssh/ /var/gerrit/.ssh
    # Scripts
COPY scripts/ /scripts
COPY config.sh ${ENTRYPOINT}/config.sh
    # SQL
COPY jenkins_user.sql /jenkins_user.sql
    # Password for PG, stored in private Git
COPY pg-gerrit-password.sh /pg-gerrit-password.sh
    # Gerrit start replace
COPY gerrit-start.sh /gerrit-start.sh
    # Gits
    # FIXME: This may later be mounted
COPY gits/ /usr/src/gerrit
    # Global repo signing keys
COPY apt-keys /var/lib/sbuild/apt-keys

# Build user
# Create build user, let it use /usr/src/. Allow jenkins also
RUN useradd build
RUN chown build:build /usr/src/ -Rf

# Let build own everything
RUN chown -R build:build /usr/src/
# But let gerrit2 own everything in gerrit
RUN chown -R gerrit2:gerrit2 /usr/src/gerrit

# Run config scripts
    # Install aptly
RUN /usr/src/aptly_setup.sh
# /Scripts
    # Start lighttpd
RUN /scripts/lighttpd_setup.sh
    # Setup gitweb
RUN /scripts/gitweb_setup.sh

# DEV ONLY REMOVE BEFORE releases
RUN apt-get update && apt-get install -y vim && rm -rf /var/lib/apt/lists/*
