#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

# Config
sed -i -e "s:/var/www/html:/srv/build:" /etc/lighttpd/lighttpd.conf
lighttpd-enable-mod cgi dir-listing accesslog

/usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf
