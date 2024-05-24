#!/bin/bash

# Only load db and modules if this script is being loaded for the first time (ie, docker run)
if [ -d "/root/temp" ]; then
    # ------------ Begin Load Database ------------

    echo "Using MySQL host: ${OPENMRS_MYSQL_HOST}"
    echo "Using MySQL port: ${OPENMRS_MYSQL_PORT}"

    # Ensure mysql is up
    while ! mysqladmin ping -h"$OPENMRS_MYSQL_HOST" -P $OPENMRS_MYSQL_PORT --silent; do
        echo "Waiting for database at '$OPENMRS_MYSQL_HOST:$OPENMRS_MYSQL_PORT'..."
        sleep 2
    done

    # Write openmrs-runtime.properties file with linked database settings
    OPENMRS_CONNECTION_URL="connection.url=jdbc:mysql://${OPENMRS_MYSQL_HOST}:${OPENMRS_MYSQL_PORT}/${DB_NAME}?autoReconnect=true&zeroDateTimeBehavior=convertToNull&sessionVariables=default_storage_engine=InnoDB&useUnicode=true&characterEncoding=UTF-8&serverTimezone=EAT"
    echo "${OPENMRS_CONNECTION_URL}" >> /root/temp/openmrs-runtime.properties
    echo "connection.username=${OPENMRS_DB_USER}" >> /root/temp/openmrs-runtime.properties
    echo "connection.password=${OPENMRS_DB_PASS}" >> /root/temp/openmrs-runtime.properties
    mkdir -pv "${OPENMRS_HOME}/${OPENMRS_NAME}"
    mkdir -pv "${OPENMRS_HOME}/${OPENMRS_NAME}/frontend"
    cp /root/temp/openmrs-runtime.properties "${OPENMRS_HOME}/${OPENMRS_NAME}/${OPENMRS_NAME}-runtime.properties" || { echo "Failed to copy runtime properties"; exit 1; }
    echo "${OPENMRS_HOME}/${OPENMRS_NAME}/${OPENMRS_NAME}-runtime.properties" 
   
    # Deploy the web application with the corrected context path
    cp /root/temp/openmrs.war "${CATALINA_HOME}/webapps/${OPENMRS_NAME}.war" || { echo "Failed to copy openmrs.war"; exit 1; }
    
    # Copy base/dependency modules to module folder
    echo "Copying module dependencies and reference application modules..."
    export OPENMRS_MODULES="${OPENMRS_HOME}/${OPENMRS_NAME}/modules"
    rm -rf "${OPENMRS_HOME}/${OPENMRS_NAME}/modules/"
    mkdir -pv "$OPENMRS_MODULES"
    cp /root/temp/modules/*.omod "$OPENMRS_MODULES" || { echo "Failed to copy modules"; exit 1; }
    rm -rf "${OPENMRS_HOME}/${OPENMRS_NAME}/.openmrs-lib-cache/"
    echo "Modules copied."
    
    # Setup microfrontends
    echo "Setting up microfrontends"
    echo "${OPENMRS_HOME}/${OPENMRS_NAME} Tuko Hapa"
    cp -r /root/temp/microfrontends/* "${OPENMRS_HOME}/${OPENMRS_NAME}/frontend/" || { echo "Failed to copy microfrontends"; exit 1; }
    cp /root/temp/microfrontends/import-map.json "${OPENMRS_HOME}/${OPENMRS_NAME}/frontend/import-map.json" || { echo "Failed to copy import-map.json"; exit 1; }
    
    # Cleanup temp files
    rm -r /root/temp || { echo "Failed to remove temp files"; exit 1; }
fi

# Setup custom memory options for Tomcat
export JAVA_OPTS="-Dfile.encoding=UTF-8 -server -Xms256m -Xmx100g  -XX:PermSize=256m -XX:MaxPermSize=100g"

# Start rsyslog and cron services if needed
# service rsyslog start || { echo "Failed to start rsyslog"; exit 1; }
# service cron start || { echo "Failed to start cron"; exit 1; }

# Start Tomcat
echo "Starting Tomcat..."
$CATALINA_HOME/bin/catalina.sh run || { echo "Failed to start Tomcat"; exit 1; }

# Tail Tomcat logs to keep the container running
tail -f $CATALINA_HOME/logs/catalina.out || { echo "Failed to tail logs"; exit 1; }
