#!/bin/bash
### In mysqld.sh (make sure this file is chmod +x):
# `/sbin/setuser mysql` runs the given command as the user `mysql`.
# If you omit that part, the command will be run as root.

exec 2>&1
if [ -z "$ZM_DB_HOST" ]; then
        exec /sbin/setuser mysql /usr/bin/mysqld_safe >>/var/log/mysqld.log 
else
        #Change db address
        sed -i 's,^\(ZM_DB_HOST=\).*,\1'$ZM_DB_HOST',' /etc/zm/zm.conf

        if [ -n "$ZM_DB_NAME" ]; then
                sed -i 's,^\(ZM_DB_NAME=\).*,\1'$ZM_DB_NAME',' /etc/zm/zm.conf
        fi

        if [ -n "$ZM_DB_USER" ]; then
                sed -i 's,^\(ZM_DB_USER=\).*,\1'$ZM_DB_USER',' /etc/zm/zm.conf
        fi

        if [ -n "$ZM_DB_PASS" ]; then
                sed -i 's,^\(ZM_DB_PASS=\).*,\1'$ZM_DB_PASS',' /etc/zm/zm.conf
        fi
fi
