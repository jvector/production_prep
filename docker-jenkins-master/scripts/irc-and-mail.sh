#!/bin/bash
# Copyright Smoothwall Ltd 2015

# If not dev environment, rename mail-disabled and irc-disabled
# so that jenkins can use them.

mv /var/jenkins_home/hudson.plugins.ircbot.IrcPublisher.xml-disabled \
   /var/jenkins_home/hudson.plugins.ircbot.IrcPublisher.xml

mv /var/jenkins_home/hudson.tasks.Mailer.xml-disabled \
   /var/jenkins_home/hudson.tasks.Mailer.xml

chown -R build:build /var/jenkins_home/
