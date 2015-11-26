#!/bin/bash

# rsync script to to copy live data to Docker container environment

source defaults.sh

JENKINS=192.168.128.28
GERRIT_LIVE=192.168.128.59

FILES_TO_COPY=$(cd .. && pwd )/files_to_copy

#Container gerrit2/build user UIDs
GERRIT_UID=1000
BUILD_UID=1001

# Note: root on the gerrit-containerhost has had his own
# ssh-keygen-generated keys copied over to the existing buildsystem
# servers using the existing 'victor' login

RSYNC_OPTS="-az --dry-run"

function copy_jenkins {
	rsync ${RSYNC_OPTS} victor@${JENKINS}:/srv/chroot/ $SRV_CHROOT_DATA/
	# 23GB
	# owned by root , 755 on source and on dest

	rsync ${RSYNC_OPTS} victor@${JENKINS}:/etc/schroot/chroot.d/* $FILES_TO_COPY/common_jenkins/chroot.d/
	# 616KB
	# owned by root , 755 on source and on dest


	rsync ${RSYNC_OPTS} victor@${JENKINS}:/var/lib/jenkins/jobs $JENKINS_DATA
	# 100GB
	# owner build (1001), 755 on server
	chown -R $BUILD_UID:$BUILD_UID $JENKINS_DATA
}

function copy_gerrit {
	# Gerrit:
	rsync ${RSYNC_OPTS} victor@$GERRIT_LIVE:/usr/src/gerrit/ $GERRIT_GIT_DATA/
	# 6GB
	# owned by gerrit2, 755 on server. Here we have user 'container' with id=1000
	chown -R $GERRIT_UID:$GERRIT_UID $GERRIT_GIT_DATA


	rsync ${RSYNC_OPTS} victor@$GERRIT_LIVE:/usr/src/repository/ $REPO_DATA/
	# 100GB
	# owner build (uid 9000) , 755 on server
	chown -R $BUILD_UID:$BUILD_UID $REPO_DATA

	rsync ${RSYNC_OPTS} victor@$GERRIT_LIVE:/usr/src/aptly/ $APTLY_DATA/
	# 65GB
	# owner build, 755
	chown -R $BUILD_UID:$BUILD_UID $APTLY_DATA

	# Database Dumps
	# owner postgres, 644

	LATEST_BUGZ_BACKUP=$(ssh victor@$GERRIT_LIVE "ls -t /global/maintenance/bugzilla_backups/ | head -1")
	OUR_BUGZ_DUMP_GZ=$FILES_TO_COPY/docker-sw-bugzilla-postgres/bugs_backup.sql.gz
	OLD_BUGZ_DUMP=$FILES_TO_COPY/docker-sw-bugzilla-postgres/bugs_backup.sql
	rsync -av victor@${GERRIT_LIVE}:/global/maintenance/bugzilla_backups/${LATEST_BUGZ_BACKUP} ${OUR_BUGZ_DUMP_GZ}
	rm ${OLD_BUGZ_DUMP}
	gunzip ${OUR_BUGZ_DUMP_GZ}

	LATEST_GERRIT_BACKUP=$(ssh victor@$GERRIT_LIVE "ls -t /global/maintenance/gerrit_backups/ | head -1")
	OUR_GERRIT_DUMP_GZ=$FILES_TO_COPY/docker-sw-gerrit-postgres/gerrit_backup.sql.gz
	OLD_GERRIT_DUMP=$FILES_TO_COPY/docker-sw-gerrit-postgres/gerrit_backup.sql
	rsync -av victor@${GERRIT_LIVE}:/global/maintenance/gerrit_backups/${LATEST_GERRIT_BACKUP} ${OUR_GERRIT_DUMP_GZ}
	rm ${OLD_GERRIT_DUMP}
	gunzip ${OUR_GERRIT_DUMP_GZ}
}

function copy_dev {
	DEV_COPY=/global/users/jonathan.barron/cbuildsystem-starter-pack
	echo "Files required are @ ${DEV_COPY}, for now come and find Jon/Victor"

	# rsync ${RSYNC_OPTS} $DEV_COPY/files_to_copy/ $FILES_TO_COPY
	# rsync ${RSYNC_OPTS} $DEV_COPY/jenkins-test/jobs $JENKINS_DATA
}
