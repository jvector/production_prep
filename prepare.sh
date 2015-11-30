#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

if [ ! $(which curl) ]; then
	apt-get update
	apt-get -y -q install curl
fi

cd ..
# Clone cbuild-secrets
# FIXME: Should be master when merged
git clone -b gerrit-containerhost --single-branch https://github.com/Smoothwall/cbuild-secrets.git

# Get merge.sh
ln -s cbuildsystem/merge.sh .

echo "Starting merge"
./merge.sh

echo "Merge completed. Now run cbuildsystem-merged/build.sh"
