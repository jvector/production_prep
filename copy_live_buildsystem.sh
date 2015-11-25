#!/bin/bash

# rsync script to to copy live data to Docker container environment

source defaults.sh

JENKINS=192.168.128.28

# Note: root on the gerrit-containerhost has had his own
# ssh-keygen-generated keys copied over to the existing buildsystem
# servers using the existing 'victor' login

RSYNC_OPTS="-az --dry-run"

rsync ${RSYNC_OPTS} victor@${JENKINS}:/srv/chroot $SRV_CHROOT_DATA/
# 23GB
# owned by root , 755 on source and on dest

rsync ${RSYNC_OPTS} victor@${JENKINS}:/etc/schroot/chroot.d/* /root/docker/files_to_copy/common_jenkins/chroot.d/
# 616KB
# owned by root , 755 on source and on dest


#rsync ${RSYNC_OPTS} victor@${JENKINS}:/var/lib/jenkins/jobs/* $JENKINS_DATA/
rsync ${RSYNC_OPTS} victor@${JENKINS}:/var/lib/jenkins/jobs /root/container-mounts/jenkins-test/
# 100GB
# owner build (1001), 755 on server
# ! 44000+ lines! so don't use *
chown -R 1001:1001 $JENKINS_DATA

# Gerrit:
GERRIT_LIVE=192.168.128.59

rsync ${RSYNC_OPTS} victor@$GERRIT_LIVE:/usr/src/gerrit/* $GERRIT_GIT_DATA/
# 6GB
# owned by gerrit2, 755 on server. Here we have user 'container' with id=1000
chown -R container:container $GERRIT_GIT_DATA


rsync ${RSYNC_OPTS} victor@$GERRIT_LIVE:/usr/src/repository/* $REPO_DATA/
# 100GB
# owner build (uid 9000) , 755 on server
chown -R 9000:9000 $REPO_DATA

rsync ${RSYNC_OPTS} victor@$GERRIT_LIVE:/usr/src/aptly/* $APTLY_DATA/
# 65GB
# owner build, 755
chown -R 9000:9000 $APTLY_DATA


# $BUILDFS:/srv/build/logs/
# rsync ${RSYNC_OPTS} BUILDFS=192.168.128.27
# 55 MB
#( not isogen, patches, smoothdoc, API )

# Database Dumps

# owner postgres, 644

LATEST_BUGZ_BACKUP=$(ssh victor@$GERRIT_LIVE "ls -t /global/maintenance/bugzilla_backups/ | head -1")
OUR_BUGZ_DUMP_GZ=$HOME/docker/files_to_copy/docker-sw-bugzilla-postgres/bugs_backup.sql.gz
OUR_BUGZ_DUMP=$HOME/docker/files_to_copy/docker-sw-bugzilla-postgres/bugs_backup.sql
rsync -av victor@${GERRIT_LIVE}:/global/maintenance/bugzilla_backups/${LATEST_BUGZ_BACKUP} ${OUR_BUGZ_DUMP}
${OUR_BUGZ_DUMP}
yes|gunzip ${OUR_BUGZ_DUMP}


LATEST_GERRIT_BACKUP=$(ssh victor@$GERRIT_LIVE "ls -t /global/maintenance/gerrit_backups/ | head -1")
OUR_GERRIT_DUMP_GZ=$HOME/docker/files_to_copy/docker-sw-gerrit-postgres/gerrit_backup.sql.gz
OUR_GERRIT_DUMP=$HOME/docker/files_to_copy/docker-sw-gerrit-postgres/gerrit_backup.sql

rsync -av victor@${GERRIT_LIVE}:/global/maintenance/gerrit_backups/${LATEST_GERRIT_BACKUP} ${OUR_GERRIT_DUMP_GZ}
rm ${OUR_GERRIT_DUMP}
yes|gunzip ${OUR_GERRIT_DUMP_GZ}

# Ensure up to date buildsystem and dev_metadata

# No need to copy to the files_to_copy area because we don't patch these
cd $DEVMETADATA_DATA
git pull

# copy to the files_to_copy area because we wish to patch these
cd /root/docker/files_to_copy/shared_src/buildsystem/
git pull






