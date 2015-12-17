#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

if [ ! $(which curl) ]; then
	apt-get update
	apt-get -y -q install curl
fi

cd ..
# Clone cbuild-secrets
git clone git@github.com:Smoothwall/cbuild-secrets.git

# Get merge.sh
ln -s cbuildsystem/merge.sh .

echo "Starting merge"
./merge.sh

echo "Merge completed. Now run cbuildsystem-merged/build.sh"
