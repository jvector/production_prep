#!/bin/bash

# rsync script to to copy live data to Docker container environment

source defaults.sh

cd /root/container-mounts

JENKINS=192.168.128.28

# Note: root on the gerrit-containerhost has had his own
# ssh-keygen-generated keys copied over to the existing buildsystem
# servers using the existing 'victor' login

RSYNC_OPTS="-az -l victor --dry-run"

#owned by root , 755
rsync ${RSYNC_OPTS} ${JENKINS}:/srv/chroot/* $SRV_CHROOT_DATA/
# 23GB


# root, 755
rsync ${RSYNC_OPTS} ${JENKINS}:/etc/schroot/chroot.d/* /root/docker/files_to_copy/common_jenkins/chroot.d/
# 616KB


# owner build, 755
rsync ${RSYNC_OPTS} ${JENKINS}:/var/lib/jenkins/jobs/*  ${JENKINS}_DATA/
# 100GB

# Gerrit:

GERRIT_LIVE=192.168.128.59

rsync ${RSYNC_OPTS} $GERRIT_LIVE:/usr/src/gerrit/* $GERRIT_GIT_DATA/
# 6GB
# gerrit2, 755


rsync ${RSYNC_OPTS} $GERRIT_LIVE:/usr/src/repository/* $REPO_DATA/
# 100GB
# owner gerrit2, 755

rsync ${RSYNC_OPTS} $GERRIT_LIVE:/usr/src/aptly/* $APTLY_DATA/
# 65GB
# owner build, 755


# $BUILDFS:/srv/build/logs/
# rsync ${RSYNC_OPTS} BUILDFS=192.168.128.27
# 55 MB
#( not isogen, patches, smoothdoc, API )

# Database Dumps

# owner postgres, 644

LATEST_BUGZ_BACKUP=$(ssh $GERRIT_LIVE "ls -t /global/maintenance/bugzilla_backups/ | head -1")
rsync -av $GERRIT_LIVE:$LATEST_BUGZ_BACKUP

# Ensure up to date buildsystem and dev_metadata

# No need to copy to the files_to_copy area because we don't patch these
cd $DEVMETADATA_DATA
git pull

# copy to the files_to_copy area because we wish to patch these
cd /root/docker/files_to_copy/shared_src/buildsystem/
git pull






