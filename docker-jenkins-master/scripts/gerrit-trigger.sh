#!/bin/bash
# Copyright Smoothwall Ltd 2015

# Do some gerrit-trigger.xml sedding here...
gosu jenkins sed -i -e "s/@GERRIT_HOSTNAME@/$GERRIT_NAME/" \
				    /var/jenkins_home/gerrit-trigger.xml

# POST jenkins api to restart & reload config
curl -X POST http://localhost:8080/restart
