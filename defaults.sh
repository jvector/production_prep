#!/bin/bash
# Copyright Smoothwall Ltd 2015

# Our settings

# This stops jenkins configuring irc/mail plugins, can Also
# be set using -d 1 on mkbuildsystem.sh
DEV=${DEV:-0}

# If your home dir is on sotonfs, or you want to use a dir other than $HOME
# put an alternative in BUILD_HOME
BUILD_HOME="${BUILD_HOME:-$HOME}/container-mounts"
DB_DUMPS=${BUILD_HOME:-$HOME}/db_dumps

APTLY_DEBIANIZER_DATA=${BUILD_HOME:-$HOME}/aptly-debianizer-test/
APTLY_DEBIANIZER_SERVE_DATA=${BUILD_HOME:-$HOME}/aptly-debianizer-serve-test/
APTLY_S3_DATA=${BUILD_HOME:-$HOME}/aptly-s3-test/
BUILDSYSTEM_DATA=${BUILD_HOME:-$HOME}/buildsystem-test/
DEVMETADATA_DATA=${BUILD_HOME:-$HOME}/dev-metadata-test/
GERRIT_GIT_DATA=${BUILD_HOME:-$HOME}/gerrit-git-data/
HOME_BUILD_DATA=${BUILD_HOME:-$HOME}/home-build-test/
VAR_GERRIT_SSH_DATA=${BUILD_HOME:-$HOME}/var-gerrit-ssh-test/
GERRIT_DATA=${BUILD_HOME:-$HOME}/gerrit-test/
JENKINS_DATA=${BUILD_HOME:-$HOME}/jenkins-test/
MNTBUILD_DATA=${BUILD_HOME:-$HOME}/mnt-build-test/
PG_BUGZILLA_DATA=${BUILD_HOME:-$HOME}/pg-bugzilla-test/
PG_GERRIT_DATA=${BUILD_HOME:-$HOME}/postgres-test/
REPO_DATA=${BUILD_HOME:-$HOME}/repo-test/
SRV_CHROOT_DATA=${BUILD_HOME:-$HOME}/srv-chroot-data/
ETC_SCHROOT_CHROOTD=${BUILD_HOME:-$HOME}/etc-schroot-chrootd-data/
