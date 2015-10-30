#!/bin/bash
# Copyright Smoothwall Ltd 2015

# BUILDUSER?
USER=jenkins

# A lot of files get copied in as root. To avoid any conflicts, here we 
# chown everything to jenkins.
chown -R ${USER}:${USER} /var/jenkins_home/

reprepro -b /usr/src/repository createsymlinks

chown -R ${USER}:${USER} /usr/src/repository
#chown -R sbuild:sbuild /var/lib/sbuild/apt-keys

# Do some configuration!
# Insert valid IP's & Executors for the Child nodes
 gosu ${USER} sed -i -e "s/@JENCHILD1_HOST@/$JENCHILD1_PORT_9500_TCP_ADDR/" \
						 -e "s/@JENCHILD2_HOST@/$JENCHILD2_PORT_9500_TCP_ADDR/" \
						 -e "s/@JENCHILD1_EXECUTORS@/$JENCHILD1_ENV_EXECUTORS/" \
						 -e "s/@JENCHILD2_EXECUTORS@/$JENCHILD2_ENV_EXECUTORS/" \
						 /var/jenkins_home/config.xml

# Configure x plugin .xml file
# ad infinitum

# There are certain config's we don't want in a dev environment, irc, mailer..
if [ ! "$DEV" = 1 ]; then
    /bin/bash /scripts/irc-and-mail.sh
fi

# Jenkins Location config
gosu ${USER} sed -i -e "s/@SYSADMINMAIL@/$SYSADMINMAIL/" \
                        /var/jenkins_home/jenkins.model.JenkinsLocationConfiguration.xml

# Integration
# Add a few extra's to sudo
cat /sudo.txt >> /etc/sudoers

# Create a convenience symlink for debootstrap script
ln -s /usr/src/buildsystem/templates/debootstrap-smoothwall /usr/share/debootstrap/scripts/smoothwall

# Gerrit trigger config
gosu ${USER} sed -i -e "s/@GERRIT_HOSTNAME@/$GERRIT_NAME/" \
				    /var/jenkins_home/gerrit-trigger.xml

exec gosu ${USER} java $JAVA_OPTS -jar /usr/share/jenkins/jenkins.war $JENKINS_OPTS "$@"
