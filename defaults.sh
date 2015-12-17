#!/bin/bash
# Copyright Smoothwall Ltd 2015

# Our settings

# This stops jenkins configuring irc/mail plugins, can Also
# be set using -d 1 on mkbuildsystem.sh
DEV=${DEV:-0}

# If your home dir is on sotonfs, or you want to use a dir other than $HOME
# put an alternative in BUILD_HOME
BUILD_HOME_CONT="${BUILD_HOME:-$HOME}/container-mounts"
DB_DUMPS=${BUILD_HOME:-$HOME}/db_dumps

# Mnt build is NFS mounted
MNTBUILD_DATA=${BUILD_HOME:-$HOME}/buildfs-mounts/mnt-build/

# Rest are on local disk
APTLY_DEBIANIZER_DATA=${BUILD_HOME_CONT}/aptly-debianizer-test
APTLY_DEBIANIZER_SERVE_DATA=${BUILD_HOME_CONT}/aptly-debianizer-serve-test
APTLY_S3_DATA=${BUILD_HOME_CONT}/aptly-s3-test
BUILDSYSTEM_DATA=${BUILD_HOME_CONT}/buildsystem-test
DEVMETADATA_DATA=${BUILD_HOME_CONT}/dev-metadata-test
HOME_BUILD_DATA=${BUILD_HOME_CONT}/home-build-test
GERRIT_GIT_DATA=${BUILD_HOME_CONT}/gerrit-git-data
VAR_GERRIT_SSH_DATA=${BUILD_HOME_CONT}/var-gerrit-ssh-test
GERRIT_DATA=${BUILD_HOME_CONT}/gerrit-test
JENKINS_DATA=${BUILD_HOME_CONT}/jenkins-test
PG_BUGZILLA_DATA=${BUILD_HOME_CONT}/pg-bugzilla-test
PG_GERRIT_DATA=${BUILD_HOME_CONT}/postgres-test
REPO_DATA=${BUILD_HOME_CONT}/repo-test
SRV_CHROOT_DATA=${BUILD_HOME_CONT}/srv-chroot-data
ETC_SCHROOT_CHROOTD=${BUILD_HOME_CONT}/etc-schroot-chrootd-data
