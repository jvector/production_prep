#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

sed -i -e "s:/var/lib/git:/usr/src/gerrit:" /etc/gitweb.conf

cat <<EOF >> /etc/lighttpd/conf-enabled/10-cgi.conf
	\$HTTP["host"] =~ "^gitweb" {
		cgi.assign = (
			".cgi" => "/usr/bin/perl"
		)
		alias.url += (
			"/gitweb.css"      => "/usr/share/gitweb/gitweb.css",
			"/git-logo.png"    => "/usr/share/gitweb/git-logo.png",
			"/git-favicon.png" => "/usr/share/gitweb/git-favicon.png",
			"/"                => "/usr/lib/cgi-bin/gitweb.cgi"
		)
	}
EOF

/etc/init.d/lighttpd restart
