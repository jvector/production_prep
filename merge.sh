#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

# create the cbuildsystem-merged directory from the latest contents of github/cbuildsystem and github/cbuild-secrets.

# should be run whenever a change is made to code in either of the above.

# in general, avoid patching directly into the cbuildsystem-merged/ directory.

# In The Future this will be done with rsync...

while getopts ":f:" opt; do
	case "$opt" in
		f)
			echo "*** Super turbo fast merge activated"
			FAST=1
			;;
	?)
			echo "*** Unknown argument $opt."
			echo "*** Only valid option is -f for 'fast' merge"
			exit
	esac
done

if [ ! -e cbuildsystem-merged/docker-sw-gerrit-postgres/gerrit_backup.sql ] ; then
	echo "*** Essential file(s) missing, forcing full merge."
	FAST=0
fi

if [ -e defaults.sh ]; then
	echo "You're trying to run this inside a work dir. cd .. and run again" && exit
fi

rm -rf cbuildsystem-merged/
mkdir cbuildsystem-merged
cp -ar cbuildsystem/*        cbuildsystem-merged/

# We are not able to save permissions in gitHub ... the secret files
# come down as default 644 perms which stops ssh starting so we need
# to force the perms back to 600

find cbuild-secrets -name ssh_host_\*key -exec chmod 600 {} \;

cp -ar cbuild-secrets/.     cbuildsystem-merged/

echo "Finished"
#######
