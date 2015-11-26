#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

source copy_live_buildsystem.sh

case "$1" in
	jenkins)
		copy_jenkins
	;;
	gerrit)
		copy_gerrit
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

cd ..
# Clone cbuild-secrets
git clone https://github.com/Smoothwall/cbuild-secrets.git
git clone http://gerrit.soton.smoothwall.net/buildsystem files_to_copy/shared_src/buildsystem
git clone http://gerrit.soton.smoothwall.net/dev-metadata files_to_copy/shared_src/dev-metadata

# Get merge.sh
ln -s cbuildsystem/merge.sh .

echo "Starting merge"
./merge.sh

echo "Merge completed. Now run cbuildsystem-merged/mkbuildsystem.sh"
