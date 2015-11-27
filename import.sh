#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

source copy_live_buildsystem.sh
source container_functions.sh

case "$1" in
	jenkins)
		copy_jenkins
	;;
	gerrit)
		copy_gerrit
		copy_db_backups
		import_db_backups
	;;
	singlehost)
#		copy_jenkins
#		copy_gerrit
		copy_db_backups
		import_db_backups
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

git clone -b <PUT BRANCH HERE> --single-branch http://gerrit.soton.smoothwall.net/buildsystem $BUILDSYSTEM_DATA
git clone http://gerrit.soton.smoothwall.net/dev-metadata $DEVMETADATA_DATA

#reload shit

#Jenkins

function reload_jenkins {
	curl -X POST http://127.0.0.1:8080/restart
}

#Gerrit

function reload_gerrit {
	docker stop $GERRIT_NAME
	docker start $GERRIT_NAME
	echo "Gerrit restarted, allow ~20s for it to start up again."
	
}
