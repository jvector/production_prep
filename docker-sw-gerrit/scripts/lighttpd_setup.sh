#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

lighttpd-enable-mod proxy
lighttpd-enable-mod cgi
lighttpd-enable-mod simple-vhost
/etc/init.d/lighttpd restart
