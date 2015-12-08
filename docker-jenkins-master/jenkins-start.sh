#!/bin/bash
# Copyright Smoothwall Ltd 2015

# For tmpfs optimization
mount -a

USER=build

# A lot of files get copied in as root. To avoid any conflicts, here we 
# chown everything to jenkins.
chown -R ${USER}:${USER} /var/jenkins_home/

gosu ${USER} reprepro -b /usr/src/repository createsymlinks

exec gosu ${USER} java $JAVA_OPTS -jar /usr/share/jenkins/jenkins.war $JENKINS_OPTS "$@"
