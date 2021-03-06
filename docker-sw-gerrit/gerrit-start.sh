#!/bin/bash
# set -e

chown -R gerrit2:gerrit2 /usr/src/gerrit

service ssh start

java -jar /var/gerrit/review_site/bin/gerrit.war init -d /var/gerrit/review_site

gosu gerrit2 java -jar /var/gerrit/gerrit.war reindex -d $GERRIT_SITE

echo "Starting Gerrit..."
exec gosu ${GERRIT_USER} $GERRIT_SITE/bin/gerrit.sh daemon
