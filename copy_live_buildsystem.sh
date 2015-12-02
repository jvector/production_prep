#!/bin/bash

# rsync script to to copy live data to Docker container environment

JENKINS=192.168.128.28
GERRIT_LIVE=192.168.128.59

#Container gerrit2/build user UIDs
GERRIT_UID=1000
BUILD_UID=1001

# Note: root on the gerrit-containerhost has had his own
# ssh-keygen-generated keys copied over to the existing buildsystem
# servers using the existing 'victor' login

RSYNC_OPTS="-az --dry-run"

function copy_jenkins_jobs {
	rsync ${RSYNC_OPTS} victor@${JENKINS}:/var/lib/jenkins/jobs $JENKINS_DATA
	# 100GB
	# owner build (1001), 755 on server
}

function copy_gerrit_gits {
	# Gerrit:
	rsync ${RSYNC_OPTS} victor@$GERRIT_LIVE:/usr/src/gerrit/ $GERRIT_GIT_DATA/
	# 6GB
	# owned by gerrit2, 755 on server. Here we have user 'container' with id=1000
}

function copy_chroots {
	rsync ${RSYNC_OPTS} victor@${JENKINS}:/srv/chroot/ $SRV_CHROOT_DATA/
	# 23GB
	# owned by root , 755 on source and on dest
}

function copy_chroot_configs {
	rsync ${RSYNC_OPTS} victor@${GERRIT_LIVE}:/etc/schroot/chroot.d/ $ETC_SCHROOT_CHROOTD/
	# 616KB
	# owned by root , 755 on source and on dest
}

function copy_internal_repo {
	rsync ${RSYNC_OPTS} victor@$GERRIT_LIVE:/usr/src/repository/ $REPO_DATA/
	# 100GB
	# owner build (uid 9000) , 755 on server
}

function copy_merged_repo {
	rsync ${RSYNC_OPTS} victor@$GERRIT_LIVE:/usr/src/aptly/ $APTLY_DATA/
	# 65GB
	# owner build, 755
}

function copy_common_gerrit_jenkins {
	copy_internal_repo
	copy_merged_repo
	copy_chroot_configs
	copy_chroots
}

function copy_jenkins {
	copy_jenkins_jobs
	copy_common_gerrit_jenkins
}

function copy_gerrit {
	copy_gerrit_gits
	copy_common_gerrit_jenkins
}

function copy_singlehost {
	copy_jenkins_jobs
	copy_gerrit_gits
	copy_common_gerrit_jenkins
}

function copy_db_backups {
	# Database Dumps
	# owner postgres, 644

	# LATEST_BUGZ_BACKUP=$(ssh victor@$GERRIT_LIVE "ls -t /global/maintenance/bugzilla_backups/ | head -1")
	# OUR_BUGZ_DUMP_GZ=$DB_DUMPS/bugs_backup.sql.gz
	# OLD_BUGZ_DUMP=$DB_DUMPS/bugs_backup.sql
	# rsync -av victor@${GERRIT_LIVE}:/global/maintenance/bugzilla_backups/${LATEST_BUGZ_BACKUP} ${OUR_BUGZ_DUMP_GZ}
	# rm ${OLD_BUGZ_DUMP}
	# gunzip ${OUR_BUGZ_DUMP_GZ}

	LATEST_GERRIT_BACKUP=$(ssh victor@$GERRIT_LIVE "ls -t /global/maintenance/gerrit_backups/ | head -1")
	OUR_GERRIT_DUMP_GZ=$DB_DUMPS/gerrit_backup.sql.gz
	OLD_GERRIT_DUMP=$DB_DUMPS/gerrit_backup.sql
	rsync -av victor@${GERRIT_LIVE}:/global/maintenance/gerrit_backups/${LATEST_GERRIT_BACKUP} ${OUR_GERRIT_DUMP_GZ}
	rm ${OLD_GERRIT_DUMP}
	gunzip ${OUR_GERRIT_DUMP_GZ}
}

function copy_dev {
	DEV_COPY=/global/users/jonathan.barron/cbuildsystem-starter-pack
	echo "Files required are @ ${DEV_COPY}, for now come and find Jon/Victor"

	sudo rsync -avz $DEV_COPY/container-mounts/ $BUILD_HOME
	sudo rsync -avz $DEV_COPY/db_dumps/ $DB_DUMPS
}
