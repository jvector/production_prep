#!/bin/bash
# Copyright Smoothwall Ltd 2015

set -e

# Add a few extra's to sudo
cat /usr/src/sudo.txt >> /etc/sudoers

# For tmpfs optimization
mount -a

echo "Starting Jenkins Child..."
exec /usr/sbin/sshd -p 9500 -D
