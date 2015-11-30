#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

source copy_live_buildsystem.sh
source container_functions.sh

# FIXME: Should be master when merged?
# git clone -b pb/containerize --single-branch http://gerrit.soton.smoothwall.net/buildsystem $BUILDSYSTEM_DATA
# git clone http://gerrit.soton.smoothwall.net/dev-metadata $DEVMETADATA_DATA

#reload shit

#Jenkins

function reload_jenkins {
	echo "Telling jenkins to reload"
	curl -X POST http://127.0.0.1:9000/restart
	# FIXME: Do this more intelligently. Ping? Poll? something.
	echo "Waiting for jenkins to reload"
	sleep 60
}

#Gerrit

function reload_gerrit {
	echo "Restarting Gerrit"
	docker stop $GERRIT_NAME
	docker start $GERRIT_NAME
	echo "Gerrit restarted, allow ~20s for it to start up again."
}

# Probably needs implementing when we put in bugzilla.
#function reload_bugzilla {}

function import_db_backups {
	# Exec and postgrscopy that stuff in for Bugz and Gerrit

	#copy the .sql's to $PG_BUGZILLA_DATA
	#cp $DB_DUMPS/bugs_backup.sql $PG_BUGZILLA_DATA
	#sudo chown $POSTGRES_USER_UID:$POSTGRES_USER_UID $DB_DUMPS/bugs_backup.sql
	#copy the .sql's to $PG_GERRIT_DATA

	sudo cp $DB_DUMPS/gerrit_backup.sql $PG_GERRIT_DATA
	sudo chown $POSTGRES_USER_UID:$POSTGRES_USER_UID $DB_DUMPS/gerrit_backup.sql

	#import into bugs
	#docker exec ${PG_BUGZILLA_NAME} psql -h 127.0.0.1 -d bugs -U bugs < /var/lib/postgresql/data/bugs_backup.sql
	# docker exec ${PG_BUGZILLA_NAME} /dbimport.sh

	#import into gerrit
	# docker exec ${PG_GERRIT_NAME} gosu postgres sh -c "psql -h 127.0.0.1 -d reviewdb -U gerrit2 < /var/lib/postgresql/data/gerrit_backup.sql"
	docker exec ${PG_GERRIT_NAME} /dbimport.sh
	echo "Databases imported."
}

case "$1" in
	jenkins)
		# copy_jenkins
		reload_jenkins
	;;
	gerrit)
		# copy_gerrit
		# copy_db_backups
		import_db_backups
		reload_gerrit
	;;
	singlehost)
		# copy_jenkins
		# copy_gerrit
		# copy_db_backups
		import_db_backups
		reload_jenkins
		reload_gerrit
	;;
	dev)
		# Not yet implemented
		copy_dev
	;;
	*)
		echo "Missing argument 'jenkins', 'gerrit', 'singlehost' or 'dev'" >&2
		exit 1
	;;
esac

change_permissions_of_mounts
