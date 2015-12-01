# Copyright Smoothwall Ltd 2015
FROM debian:jessie

ARG SERVER_ROOT=/var/www/html

RUN apt-get update \
	&& apt-get install -y --no-install-recommends lighttpd \
	&& rm -rf /var/lib/apt/lists/*

RUN sed -i -e "s:/var/www/html:${SERVER_ROOT}:" /etc/lighttpd/lighttpd.conf
RUN lighttpd-enable-mod cgi dir-listing accesslog

EXPOSE 80

ENTRYPOINT [ "lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf" ]
