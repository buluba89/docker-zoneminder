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
        
        #All tables that zoneminder has 
        ZM_TABLES=(Config ControlPresets Controls Devices Events Frames Groups Logs MonitorPresets Monitors States Stats TriggersX10 Users ZonePresets Zones)
        
        #Check if all tables exists in the database  
        for i in "${ZM_TABLES[@]}"; do

               #If one doesnt exists recreate database
               if [ $(mysql -N -s -u $ZM_DB_USER -p$ZM_DB_PASS --host=$ZM_DB_HOST  -e \
                                               "select count(*) from information_schema.tables where \
                                                table_schema='${ZM_DB_NAME}' and table_name='${i}';") -ne 1 ]; then
                      
                      echo table $i does not exists, recreating database

                      mysql -u $ZM_DB_USER -p$ZM_DB_PASS --host=$ZM_DB_HOST $ZM_DB_NAME < /usr/share/zoneminder/db/zm_create.sql

                      echo Database recreated
                      break

               fi
        done
	
	#Sleep forever so the init doesnt try to restart this service
	exec /bin/sleep infinity
fi
