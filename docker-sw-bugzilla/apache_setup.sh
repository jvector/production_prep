#!/bin/bash
 # Copyright Smoothwall Ltd 2015

# Enable cgi module for apache2
a2enmod cgi

cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
        ServerAdmin $ADMIN_EMAIL
        DocumentRoot $BUGZILLA_ROOT
        <Directory $BUGZILLA_ROOT>
                Options ExecCGI
                AddHandler cgi-script .cgi
                Require all granted
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
