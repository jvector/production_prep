#!/bin/bash
# Copyright Smoothwall Ltd 2015

function set_gerrit_config {
  gosu ${GERRIT_USER} git config -f "${GERRIT_SITE}/etc/gerrit.config" $@
}

function set_secure_config {
  gosu ${GERRIT_USER} git config -f "${GERRIT_SITE}/etc/secure.config" $@
}

# Smoothwall specific settings
# set_gerrit_config auth.trustedOpenID 'https://www.google.com/accounts/o8/id?id='
# set_gerrit_config core.streamFileThreshold '100 m'
# set_gerrit_config gitweb.url 'http://gitweb.newbs.soton.smoothwall.net/'
set_gerrit_config gerrit.basePath '/usr/src/gerrit'
# 
# gosu ${GERRIT_USER} curl -L https://github.com/davido/gerrit-oauth-provider/releases/download/v0.3/gerrit-oauth-provider.jar -o ${GERRIT_SITE}/plugins/gerrit-oauth-provider.jar
# 
# set_gerrit_config auth.type OAUTH
set_gerrit_config auth.type DEVELOPMENT_BECOME_ANY_ACCOUNT
# set_gerrit_config auth.allowGoogleAccountUpgrade true
# set_gerrit_config plugin.gerrit-oauth-provider-google-oauth.client-id 263251712050-3liqjq40ji336id337c63lo1evmf0d0g.apps.googleusercontent.com
# set_gerrit_config plugin.gerrit-oauth-provider-google-oauth.link-to-existing-open-id-accounts true
# set_secure_config plugin.gerrit-oauth-provider-google-oauth.client-secret _O3-5P73V3L9gQfyq_AeEKzo

# Sym link the /usr/src/buildsystem/gerrithooks to /var/gerrit/review_site/hooks. Where they're expected
mkdir -p /var/gerrit/review_site/hooks 
chown gerrit2:gerrit2 /var/gerrit/review_site/hooks
ln -sf /usr/src/buildsystem/gerrithooks/change-merged /var/gerrit/review_site/hooks/change-merged
ln -sf /usr/src/buildsystem/gerrithooks/patchset-created /var/gerrit/review_site/hooks/patchset-created

# Get the Jenkins CLI
wget -P /var/gerrit/review_site http://${JK_PORT_8080_TCP_ADDR}:8080/jnlpJars/jenkins-cli.jar
chown -R  ${GERRIT_USER}:${GERRIT_USER} /var/gerrit/

# Save GERRIT_ADDR into ENV - not working
#export GERRIT_ADDR=${GERRIT_ADDR}:$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

#[commentlink "bugzilla"]
#  match = "(bug\\s+#?)(\\d+)"
#  link = http://bugzilla.soton.smoothwall.net/show_bug.cgi?id=$2
