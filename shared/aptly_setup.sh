#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

echo 'deb http://repo.aptly.info/ squeeze main' >> /etc/apt/sources.list
apt-key adv --keyserver keys.gnupg.net --recv-keys E083A3782A194991
apt-get update
apt-get install -y aptly
rm -rf /var/lib/apt/lists/*
mkdir /usr/src/aptly

chown build:build /usr/src/aptly
