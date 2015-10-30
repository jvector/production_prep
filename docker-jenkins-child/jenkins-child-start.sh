#!/bin/bash
# Copyright Smoothwall Ltd 2015

set -e
echo "Starting Jenkins Child..."
exec /usr/sbin/sshd -p 9500 -D
