# Copyright Smoothwall Ltd 2015
FROM debian:jessie

RUN apt-get update \
	&& apt-get install -y --no-install-recommends lighttpd \
	&& rm -rf /var/lib/apt/lists/*

RUN sed -i -e "s:/var/www/html:/mnt/build:" /etc/lighttpd/lighttpd.conf
RUN lighttpd-enable-mod cgi dir-listing accesslog

ENTRYPOINT [ "lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf" ]
