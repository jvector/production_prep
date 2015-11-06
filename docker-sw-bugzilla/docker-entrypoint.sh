#!/bin/bash
# Copyright Smoothwall Ltd 2015

if [ -e /bugzilla-secret-password.sh ]; then
    source /bugzilla-secret-password.sh
fi

if [ "$1" = "/bugzilla-start.sh" ]; then
    echo "First time initialize bugzilla.."
    chown -R $BUGZILLA_USER $BUGZILLA_ROOT

    cat <<EOF > /checksetup_answers.txt
        \$answer{'ADMIN_EMAIL'} = '$ADMIN_EMAIL'; 
    	\$answer{'ADMIN_OK'} = 'Y';
    	\$answer{'ADMIN_PASSWORD'} = '$ADMIN_PASSWORD';
    	\$answer{'ADMIN_REALNAME'} = 'Admin';
    	\$answer{'db_check'} = 1;
    	\$answer{'db_driver'} = '$DB_DRIVER';
    	\$answer{'db_host'} = '$DB_HOST';
    	\$answer{'db_name'} = '$DB_NAME',
    	\$answer{'db_pass'} = '$DB_PASS';
    	\$answer{'db_port'} = $DB_PORT;
    	\$answer{'db_user'} = '$DB_USER';
    	\$answer{'webservergroup'} = '$WEB_SERVER_GROUP';
EOF
    mv /checksetup_answers.txt $BUGZILLA_ROOT

echo
for f in /docker-entrypoint-init.d/*; do
    case "$f" in
        *.sh)   echo "$0: running $f"; . "$f" ;;
        *.sql)  echo "$0: running $f"; psql -U $DB_USER -d $DB_NAME -h $DB_HOST < $f && echo;;
        *)      echo "$0: ignoring $f" ;;
    esac
    echo
done
fi
exec "$@"
