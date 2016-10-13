#!/bin/sh

ADMIN_EMAIL="pir@csuc.cat"
ADMIN_PASSWD="csuc2016"

# creant usuari dspace
useradd -m dspace
echo "dspace:dspace"|chpasswd
chown dspace /dspace


#Baixo i Compilo el DSpace
DPSACE_TGZ_URL=https://github.com/DSpace/DSpace/archive/dspace-5.6.tar.gz
curl -L "$DPSACE_TGZ_URL" -o /tmp/dspace.tar.gz
tar -xvf /tmp/dspace.tar.gz --strip-components=1  -C /projectes/src/dspace


#Si no hi ha cap dspace instal·lat farem fresh install, sinó update
if [ -d "/dspace/webapps" ]; then
	echo "dspace update"
    cd /projectes/src/dspace && mvn package && cd dspace/target/dspace-installer && ant update
else
    # Creant base de dades
	psql -U postgres -c "CREATE USER dspace WITH LOGIN PASSWORD 'dspace';"
	psql -U postgres -c "CREATE DATABASE dspace;"
	psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE dspace TO dspace;"
	sleep 5s
    echo "fresh_install"
    cd /projectes/src/dspace && mvn package && cd dspace/target/dspace-installer && ant fresh_install
    if [ -z "$ADMIN_EMAIL" ]; then
       echo "Admin email must be specified"
       exit 1
    else
       echo "Creating admin user $ADMIN_EMAIL $ADMIN_PASSWD"
       /dspace/bin/dspace create-administrator -e ${ADMIN_EMAIL} -f DSpace -l Admin -p ${ADMIN_PASSWD} -c en
    fi  
fi

