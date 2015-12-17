#!/bin/bash
# Copyright Smoothwall Ltd 2015

set -e

# Add a few extra's to sudo
cat /usr/src/sudo.txt >> /etc/sudoers

# Create a convenience symlink for debootstrap script
ln -sf /usr/src/buildsystem/templates/debootstrap-smoothwall /usr/share/debootstrap/scripts/smoothwall

# For tmpfs optimization
mount -a

echo "Starting Jenkins Child..."
exec /usr/sbin/sshd -p 9500 -D
