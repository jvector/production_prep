#!/bin/bash
# Copyright Smoothwall Ltd 2015

# Our settings

# This stops jenkins configuring irc/mail plugins, can Also
# be set using -d 1 on mkbuildsystem.sh
DEV=${DEV:-0}

# If your home dir is on sotonfs, or you want to use a dir other than $HOME
# put an alternative in BUILD_HOME
BUILD_HOME="${BUILD_HOME:-$HOME}/buildfs-mounts"
DB_DUMPS=${BUILD_HOME:-$HOME}/db_dumps

MNTBUILD_DATA=${BUILD_HOME:-$HOME}/mnt-build/

APTLY_DEBIANIZER_DATA=${BUILD_HOME:-$HOME}/container_data/aptly-debianizer
APTLY_DEBIANIZER_SERVE_DATA=${BUILD_HOME:-$HOME}/container_data/aptly-debianizer-serve
APTLY_S3_DATA=${BUILD_HOME:-$HOME}/container_data/aptly-s3
BUILDSYSTEM_DATA=${BUILD_HOME:-$HOME}/container_data/buildsystem
DEVMETADATA_DATA=${BUILD_HOME:-$HOME}/container_data/dev-metadata
HOME_BUILD_DATA=${BUILD_HOME:-$HOME}/container_data/home
GERRIT_GIT_DATA=${BUILD_HOME:-$HOME}/container_data/gerrit-gits
VAR_GERRIT_SSH_DATA=${BUILD_HOME:-$HOME}/container_data/var-gerrit-ssh
GERRIT_DATA=${BUILD_HOME:-$HOME}/container_data/gerrit-home
JENKINS_DATA=${BUILD_HOME:-$HOME}/container_data/jenkins-home
PG_BUGZILLA_DATA=${BUILD_HOME:-$HOME}/container_data/pg-bugzilla-db
PG_GERRIT_DATA=${BUILD_HOME:-$HOME}/container_data/pg-gerrit-db
REPO_DATA=${BUILD_HOME:-$HOME}/container_data/repository
SRV_CHROOT_DATA=${BUILD_HOME:-$HOME}/container_data/srv-chroot
ETC_SCHROOT_CHROOTD=${BUILD_HOME:-$HOME}/container_data/etc-schroot-chrootd
