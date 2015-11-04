#!/bin/bash
set -e

psql -U gerrit2 -d reviewdb -h $DATABASE_HOSTNAME < /jenkins_user.sql

java -jar /var/gerrit/review_site/bin/gerrit.war init -d /var/gerrit/review_site

echo "Starting Gerrit..."
exec gosu ${GERRIT_USER} $GERRIT_SITE/bin/gerrit.sh daemon
