#!/bin/bash
# Copyright Smoothwall Ltd 2015

source pg-gerrit-password.sh

function set_gerrit_config {
  gosu ${GERRIT_USER} git config -f "${GERRIT_SITE}/etc/gerrit.config" $@
}

function set_secure_config {
  gosu ${GERRIT_USER} git config -f "${GERRIT_SITE}/etc/secure.config" $@
}

# Possibly not needed
# set_gerrit_config gitweb.url 'http://$HOST/'

# Smoothwall specific settings
set_gerrit_config auth.trustedOpenID 'https://www.google.com/accounts/o8/id?id='
# set_gerrit_config core.streamFileThreshold '100 m'
set_gerrit_config gerrit.basePath '/usr/src/gerrit'
# 
gosu ${GERRIT_USER} curl -L https://github.com/davido/gerrit-oauth-provider/releases/download/v0.3/gerrit-oauth-provider.jar -o ${GERRIT_SITE}/plugins/gerrit-oauth-provider.jar
# 
# For debug use ..
# set_gerrit_config auth.type DEVELOPMENT_BECOME_ANY_ACCOUNT

set_gerrit_config auth.type OAUTH
set_gerrit_config auth.allowGoogleAccountUpgrade true
set_gerrit_config plugin.gerrit-oauth-provider-google-oauth.client-id 263251712050-3liqjq40ji336id337c63lo1evmf0d0g.apps.googleusercontent.com
set_gerrit_config plugin.gerrit-oauth-provider-google-oauth.link-to-existing-open-id-accounts true
set_secure_config plugin.gerrit-oauth-provider-google-oauth.client-secret _O3-5P73V3L9gQfyq_AeEKzo

# Sym link the /usr/src/buildsystem/gerrithooks to /var/gerrit/review_site/hooks. Where they're expected
mkdir -p /var/gerrit/review_site/hooks 
chown gerrit2:gerrit2 /var/gerrit/review_site/hooks
ln -sf /usr/src/buildsystem/gerrithooks/change-merged /var/gerrit/review_site/hooks/change-merged
ln -sf /usr/src/buildsystem/gerrithooks/patchset-created /var/gerrit/review_site/hooks/patchset-created
ln -sf /usr/src/buildsystem/gerrithooks/ref-updated /var/gerrit/review_site/hooks/ref-updated

# Link in the aptly config from buildsystem (this one call does it for all containers)
ln -sf /usr/src/buildsystem/aptly-debianizer/aptly.conf /usr/src/aptly-debianizer/aptly.conf
ln -sf /usr/src/buildsystem/aptly-s3/aptly.conf /usr/src/aptly-s3/aptly.conf

chown -R  ${GERRIT_USER}:${GERRIT_USER} /var/gerrit/

# This was previously handled via linking in pg-gerrit as db and specifying DATABASE_TYPE
# but docker 1.9 breaks this. If we wan't the containers to be able to communicate via
# hostname/container name they must be on the non-default bridge network. And linking on
# custom networks is not allowed.
set_gerrit_config database.type "postgresql"
set_gerrit_config database.hostname "${DATABASE_HOSTNAME}"
set_gerrit_config database.port "5432"
set_gerrit_config database.database "reviewdb"
set_gerrit_config database.username "gerrit2"
# This comes from pg-gerrit-password.sh in cbuild-secrets
set_secure_config database.password "${PGPASSWORD}"

# Integration
# Add a few extra's to sudo
cat /sudo.txt >> /etc/sudoers

cp -a /etc_copy/* ${GERRIT_SITE}/etc

service lighttpd start

# Create a convenience symlink for debootstrap script
ln -sf /usr/src/buildsystem/templates/debootstrap-smoothwall /usr/share/debootstrap/scripts/smoothwall

set_gerrit_config httpd.listenUrl "proxy-http://*:8080/"

set_gerrit_config user.email "gerrit@gerrit.container.soton.smoothwall.net"
