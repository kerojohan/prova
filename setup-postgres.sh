#!/bin/bash

#Si no hi ha cap dspace instal·lat farem fresh install, sinó update
if [ -d "/postgres/main" ]; then
    echo "DSpace ja instalat en aquesta instància"
    rm -rf /var/lib/postgresql/9.4/main
    chown -R postgres:postgres /postgres
    ln -s /postgres/main /var/lib/postgresql/9.4/main
	chown -R postgres:postgres /var/lib/postgresql/9.4/main
else
    echo "No existeix cap instància anterior de DSpace"
    cp -R /var/lib/postgresql/9.4/main /postgres
	rm -rf /var/lib/postgresql/9.4/main
	chown -R postgres:postgres /postgres
	chmod 777 /postgres
	ln -s /postgres/main /var/lib/postgresql/9.4/main
	chown -R postgres:postgres /var/lib/postgresql/9.4/main	
fi


#permissos per compartir la carpeta de les dades del postgres
sed -i "s/local   all             postgres                                peer/local   all             postgres                                trust/g" /etc/postgresql/9.4/main/pg_hba.conf
#modificació tomcat
echo "local all dspace md5" >> /etc/postgresql/9.4/main/pg_hba.conf


echo "ENGEGANT POSTGRES"
/etc/init.d/postgresql start
