# Copyright Smoothwall Ltd 2015
# https://hub.docker.com/r/openfrontier/gerrit/
FROM debian:jessie
MAINTAINER Smoothwall Ltd <maintenance@smoothwall.net>

ARG BUILD_USER_PASSWORD

# Prevents invoke-rc.d errors
RUN sed -i -e "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

RUN apt-get update && apt-get -y upgrade \
&& apt-get -q -y install \
					default-jre \
					build-essential \
					git \
					openssh-server \
					ntpdate \
					rpcbind \
					sbuild \
					doxygen reprepro \
					git-buildpackage liblog-log4perl-perl \
					libtest-spec-perl libtest-mockmodule-perl \
					libtest-mockobject-perl \
					libmoosex-log-log4perl-perl \
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

# jenchild1 server setup from wiki , up to 'Needed Packages' section..
RUN useradd -s /bin/bash -u 1001 build
RUN echo "build:$BUILD_USER_PASSWORD" | sudo chpasswd

# buildsystem - Common files are copied in via mkbuildsystem script.
# If you want to build this manually, and the files don't exist it will error.
# Circumvent this by copying manually from one level up, or run copy_shared in
# container_functions.sh
COPY shared /usr/src/
RUN chown -R build:build /usr/src/

# Put patch-configuration in the right place
RUN mv /usr/src/patch-configuration.json /etc/patch-configuration.json

COPY jenkins-child-entrypoint.sh /jenkins-child-entrypoint.sh
COPY jenkins-child-start.sh /jenkins-child-start.sh

RUN chmod +x /jenkins-child-entrypoint.sh
RUN chmod +x /jenkins-child-start.sh

# Static Analysis Tools
RUN git clone https://github.com/hubnerd/pod2projdocs.git /root/pod2projdocs \
	&& cd /root/pod2projdocs \
	&& perl Makefile.PL PREFIX=/usr \
	&& make \
	&& make install \
	&& rm -Rf /root/pod2projdocs \
	&& cd -

# Global repo signing key
COPY apt-keys /var/lib/sbuild/apt-keys

# Change sbuild.conf to allow env variables
# Relies on shared_src file's existing in /this/ dir, see above
COPY shared/sbuild.conf /etc/sbuild/sbuild.conf

# sbuild user config
RUN sbuild-adduser build
COPY .sbuildrc /home/build/.sbuildrc

# Install aptly
RUN /usr/src/aptly_setup.sh

# sbuild global config
COPY smoothwall/ /etc/schroot/smoothwall
RUN ln -s /usr/src/buildsystem/sbuildhooks/sbuild-hook-addbuilduser /etc/schroot/setup.d/30addbuilduser

ENTRYPOINT ["/jenkins-child-entrypoint.sh"]

EXPOSE 9500

# DEV ONLY REMOVE BEFORE releases
RUN apt-get update && apt-get -y install vim && rm -rf /var/lib/apt/lists/*

# tmpfs optimization - requires a mount -a in start script
COPY fstab /etc/fstab

CMD ["/jenkins-child-start.sh"]
