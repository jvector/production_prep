#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

# This script is not to be ran at startup,
# it is to be called on demand by import.sh.

# This fixes context issues when using docker exec.
gosu postgres psql -d reviewdb -U gerrit2 < /var/lib/postgresql/data/gerrit_backup.sql
