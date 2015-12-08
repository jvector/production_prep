# Copyright Smoothwall Ltd 2015
# https://hub.docker.com/r/openfrontier/gerrit/
FROM jenkins:1.609.3
MAINTAINER Smoothwall Ltd <maintenance@smoothwall.net>

ARG BUILD_USER_PASSWORD

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade \
	&& apt-get -q -y install \
					openssh-server \
					ntpdate \
					build-essential \
					doxygen reprepro \
					sbuild git-buildpackage dh-autoreconf liblog-log4perl-perl \
					libtest-spec-perl libtest-mockmodule-perl \
					libtest-mockobject-perl libmoosex-log-log4perl-perl \
					libfile-copy-recursive-perl libdatetime-perl \
					cppcheck libperl-critic-perl \
					libdevel-cover-perl libconfig-inifiles-perl \
					libdatetime-perl libemail-mime-perl \
					libemail-sender-perl libfile-chdir-perl \
					libfile-copy-recursive-perl libfile-slurp-perl \
					libfilesys-df-perl libhttp-message-perl \
					libio-stringy-perl libipc-run-perl libjson-perl \
					liblog-log4perl-perl libwww-perl \
					libmoose-perl \
					libparse-debcontrol-perl libredis-perl \
					libterm-vt102-perl libtest-mockmodule-perl \
					libtest-mockobject-perl libtest-spec-perl \
					libthread-pool-simple-perl libtry-tiny-perl \
					liburi-perl libwww-bugzilla-perl libxml-dom-perl \
					libxml-dom-xpath-perl \
	&& rm -rf /var/lib/apt/lists/*

# This needs to be added once we figure out how to pass it
# Arguments
# nis \
# nfs-common, portmap

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

# Static Analysis Tools
RUN git clone https://github.com/hubnerd/pod2projdocs.git /root/pod2projdocs \
	&& cd /root/pod2projdocs \
	&& perl Makefile.PL PREFIX=/usr \
	&& make \
	&& make install \
	&& rm -Rf /root/pod2projdocs \
	&& cd -

# Change sbuild.conf to allow env variables
# Relies on shared_src file's existing in /this/ dir, see above
COPY shared/sbuild.conf /etc/sbuild/sbuild.conf

#COPY
	# buildsystem - Common files are copied in via mkbuildsystem script. If
	# you want to build this manually, and the files don't exist it will error.
	# Circumvent this by copying manually from one level up, or run copy_shared in
	# container_functions.sh
COPY shared /usr/src/
COPY jenkins-start.sh /
	# Global repo signing key
COPY apt-keys /var/lib/sbuild/apt-keys

# Create build user, let it use /usr/src/. Allow jenkins also
RUN useradd -s /bin/bash -u 1001 build
RUN echo "build:$BUILD_USER_PASSWORD" | sudo chpasswd

RUN chown build:build /usr/src/ -Rf

# Put patch-configuration in the right place
RUN mv /usr/src/patch-configuration.json /etc/patch-configuration.json

# Install aptly
RUN /usr/src/aptly_setup.sh

# sbuild user config
RUN sbuild-adduser build
COPY .sbuildrc /home/build/.sbuildrc

# sbuild global config
COPY smoothwall/ /etc/schroot/smoothwall
RUN ln -s /usr/src/buildsystem/sbuildhooks/sbuild-hook-addbuilduser /etc/schroot/setup.d/30addbuilduser

# DEV ONLY REMOVE BEFORE releases
RUN apt-get update && apt-get install -y vim && rm -rf /var/lib/apt/lists/*

# tmpfs optimization - requires a mount -a in start script
COPY fstab /etc/fstab

CMD ["/jenkins-start.sh"]
