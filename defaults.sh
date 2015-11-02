#!/bin/bash
# Copyright Smoothwall Ltd 2015

# Our settings

# This stops jenkins configuring irc/mail plugins, can Also
# be set using -d 1 on mkbuildsystem.sh
DEV=1

# If your home dir is on sotonfs, or you want to use a dir other than $HOME
# put an alternative in BUILD_HOME
#BUILD_HOME=""

PG_GERRIT_DATA=${BUILD_HOME:-$HOME}/postgres-test
GERRIT_DATA=${BUILD_HOME:-$HOME}/gerrit-test
JENKINS_DATA=${BUILD_HOME:-$HOME}/jenkins-test/jobs
REPO_DATA=${BUILD_HOME:-$HOME}/repo-test/
HOME_BUILD_DATA=${BUILD_HOME:-$HOME}/home-build-test/
