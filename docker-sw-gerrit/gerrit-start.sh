#!/bin/bash
set -e

source pg-gerrit-password.sh

psql -U gerrit2 -d reviewdb -h $DB_PORT_5432_TCP_ADDR < /jenkins_user.sql

java -jar /var/gerrit/review_site/bin/gerrit.war init -d /var/gerrit/review_site

echo "Starting Gerrit..."
exec gosu ${GERRIT_USER} $GERRIT_SITE/bin/gerrit.sh daemon
