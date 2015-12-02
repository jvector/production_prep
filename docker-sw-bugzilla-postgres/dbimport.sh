#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

# This script is not to be ran at startup,
# it is to be called on demand by import.sh.

# This fixes context issues when using docker exec.
gosu postgres psql -d bugs -U bugs < /var/lib/postgresql/data/bugs_backup.sql
