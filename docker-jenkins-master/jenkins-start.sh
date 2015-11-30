#!/bin/bash
# Copyright Smoothwall Ltd 2015

USER=build

# A lot of files get copied in as root. To avoid any conflicts, here we 
# chown everything to jenkins.
chown -R ${USER}:${USER} /var/jenkins_home/

gosu ${USER} reprepro -b /usr/src/repository createsymlinks

# Link in the aptly config from buildsystem (this one call does it for all containers)
# Uncomment this when we have a dev-aptly environment and won't break anything on live
#ln -s /usr/src/buildsystem/aptly/aptly.conf /usr/src/aptly/aptly.conf

# Do some configuration!
# Insert valid IP's & Executors for the Child nodes
 gosu ${USER} sed -i -e "s/@JENCHILD1_HOST@/$JENCHILD1_HOSTNAME/" \
						 -e "s/@JENCHILD2_HOST@/$JENCHILD2_HOSTNAME/" \
						 -e "s/@JENCHILD1_EXECUTORS@/$JENCHILD1_EXECUTORS/" \
						 -e "s/@JENCHILD2_EXECUTORS@/$JENCHILD2_EXECUTORS/" \
                         -e "s#@BUILDLOG_ADDR@#$BUILDLOGS_URL#g" \
						 /var/jenkins_home/config.xml

# Configure x plugin .xml file
# ad infinitum

# There are certain config's we don't want in a dev environment, irc, mailer..
if [ ! "$DEV" = 1 ]; then
    /bin/bash /scripts/irc-and-mail.sh
fi

# Jenkins Location config
gosu ${USER} sed -i -e "s/@SYSADMINMAIL@/$SYSADMINMAIL/" \
                    -e "s/@HOST@/$HOST/" \
                        /var/jenkins_home/jenkins.model.JenkinsLocationConfiguration.xml

# Create a convenience symlink for debootstrap script
ln -s /usr/src/buildsystem/templates/debootstrap-smoothwall /usr/share/debootstrap/scripts/smoothwall

# Gerrit trigger config
gosu ${USER} sed -i -e "s/@GERRIT_HOSTNAME@/$GERRIT_NAME/" \
				    /var/jenkins_home/gerrit-trigger.xml

exec gosu ${USER} java $JAVA_OPTS -jar /usr/share/jenkins/jenkins.war $JENKINS_OPTS "$@"
