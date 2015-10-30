#!/bin/bash
# Copyright Smoothwall Ltd 2015

# Do some gerrit-trigger.xml sedding here...
 gosu jenkins sed -i -e "s/@SYSADMINMAIL@/$SYSADMINMAIL/" \
	    	/var/jenkins_home/jenkins.model.JenkinsLocationConfiguration.xml
