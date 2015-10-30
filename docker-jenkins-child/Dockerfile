# Copyright Smoothwall Ltd 2015
# https://hub.docker.com/r/openfrontier/gerrit/
FROM debian:jessie
MAINTAINER Smoothwall Ltd <maintenance@smoothwall.net>

ENV EXECUTORS 2

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
RUN useradd -m jenkins

# buildsystem - Common files are copied in via mkbuildsystem script.
# If you want to build this manually, and the files don't exist it will error.
# Circumvent this by copying manually from one level up, or run copy_shared in
# container_functions.sh
COPY shared_build /usr/src/
RUN chown -R jenkins:jenkins /usr/src/buildsystem

COPY .ssh /home/jenkins/.ssh
COPY ssh_conf /home/jenkins/.ssh/config
RUN chown -R jenkins:jenkins /home/jenkins/.ssh

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

# FIXME: This should be mounted via buildfs, for now we make our
# own scratch folder for builds to run in.
# BUILDUSER?
RUN mkdir -p /mnt/build/.debian-results && chown -R jenkins:jenkins /mnt/build

RUN chmod -R 777 /mnt/build

# Copy in Chroots
# FIXME: Should be just copy all chroots in/mount them. For now we just have 
# a few to test with, as the full set is ~100GB
COPY chroot/ /srv/chroot
# Copy in Chroot config's
# FIXME: Should be just copy all chroot.d's in. Which themselves are generated/pulled
# on demand from live. For now we have copies of these files.
COPY chroot.d/reviewed-edinburgh-i386-sbuild /etc/schroot/chroot.d/reviewed-edinburgh-i386-sbuild
COPY chroot.d/reviewed-edinburgh-amd64-sbuild /etc/schroot/chroot.d/reviewed-edinburgh-amd64-sbuild

# BUILDUSER?
# GPG keys
# If build user is used this goes away. But for now we have to point this at
# A non-standard place so that it matches jenmaster. Logically should be /home/jenkins
# For now copy it into both, with the hope we can standardise/clean up later.
COPY .gnupg/ /var/jenkins_home/.gnupg
RUN chown -R jenkins:jenkins /var/jenkins_home/
# GPG Keys
COPY .gnupg/ /home/jenkins/.gnupg
# Global repo signing key
COPY apt-keys /var/lib/sbuild/apt-keys

# Change sbuild.conf to allow env variables
# Relies on shared_build file's existing in /this/ dir, see above
COPY shared_build/sbuild.conf /etc/sbuild/sbuild.conf

# BUILDUSER?
# For now this is jenkins, might need changing to build.
# sbuild user config
RUN sbuild-adduser jenkins
COPY .sbuildrc /var/jenkins_home/.sbuildrc

# sbuild global config
COPY smoothwall/ /etc/schroot/smoothwall
RUN ln -s /usr/src/buildsystem/sbuildhooks/sbuild-hook-addbuilduser /etc/schroot/setup.d/30addbuilduser

RUN chown -R jenkins:jenkins /home/jenkins

ENTRYPOINT ["/jenkins-child-entrypoint.sh"]

EXPOSE 9500

# DEV ONLY REMOVE BEFORE releases
RUN apt-get update && apt-get -y install vim && rm -rf /var/lib/apt/lists/*

CMD ["/jenkins-child-start.sh"]