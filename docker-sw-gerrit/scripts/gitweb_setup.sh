#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

sed -i -e "s:/var/lib/git:/usr/src/gerrit:" /etc/gitweb.conf

cat <<EOF >> /etc/lighttpd/conf-enabled/10-cgi.conf
	\$HTTP["host"] =~ "$HOST" {
		cgi.assign = (
			".cgi" => "/usr/bin/perl"
		)
		alias.url += (
			"/static/gitweb.css"      => "/usr/share/gitweb/static/gitweb.css",
			"/static/git-logo.png"    => "/usr/share/gitweb/static/git-logo.png",
			"/static/git-favicon.png" => "/usr/share/gitweb/static/git-favicon.png",
			"/"                       => "/usr/lib/cgi-bin/gitweb.cgi"
		)
	}
EOF
