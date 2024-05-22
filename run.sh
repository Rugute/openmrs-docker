#!/bin/bash

# Set Tomcat home directory
export CATALINA_HOME=/usr/local/tomcat


# Function to check if MySQL is available
wait_for_mysql() {
    while ! mysqladmin ping -h"$OPENMRS_MYSQL_HOST" -P"$OPENMRS_MYSQL_PORT" --silent; do
        echo "Waiting for database at '$OPENMRS_MYSQL_HOST:$OPENMRS_MYSQL_PORT'..."
        sleep 2
    done
}

# Call the wait_for_mysql function to ensure MySQL is available
wait_for_mysql

# Function to setup OpenMRS
setup_openmrs() {
    echo "Using MySQL host: ${OPENMRS_MYSQL_HOST}"
    echo "Using MySQL port: ${OPENMRS_MYSQL_PORT}"

    # Wait for MySQL to be available
    wait_for_mysql

    # Write database connection properties to openmrs-runtime.properties
    OPENMRS_CONNECTION_URL="connection.url=jdbc:mysql://${OPENMRS_MYSQL_HOST}:${OPENMRS_MYSQL_PORT}/${DB_NAME}?autoReconnect=true&zeroDateTimeBehavior=convertToNull&sessionVariables=default_storage_engine=InnoDB&useUnicode=true&characterEncoding=UTF-8"
    echo "${OPENMRS_CONNECTION_URL}" >> "${OPENMRS_HOME}/${OPENMRS_NAME}/${OPENMRS_NAME}-runtime.properties"
    echo "connection.username=${OPENMRS_DB_USER}" >> "${OPENMRS_HOME}/${OPENMRS_NAME}/${OPENMRS_NAME}-runtime.properties"
    echo "connection.password=${OPENMRS_DB_PASS}" >> "${OPENMRS_HOME}/${OPENMRS_NAME}/${OPENMRS_NAME}-runtime.properties"

    # Copy OpenMRS war file
    cp /root/temp/openmrs.war "${CATALINA_HOME}/webapps/${OPENMRS_NAME}.war"

    # Copy modules and microfrontends
    cp /root/temp/modules/*.omod "${OPENMRS_HOME}/${OPENMRS_NAME}/modules"
    cp -r /root/temp/microfrontends/* "${OPENMRS_HOME}/${OPENMRS_NAME}/frontend"
    cp /root/temp/microfrontends/import-map.json "${OPENMRS_HOME}/${OPENMRS_NAME}/frontend/import-map.json"

    # Cleanup temp files
    rm -r /root/temp
}

# Setup custom memory options for Tomcat
export JAVA_OPTS="-Dfile.encoding=UTF-8 -server -Xms256m -Xmx100g  -XX:PermSize=256m -XX:MaxPermSize=100g"

# Start rsyslog and cron services
service rsyslog start
service cron start

# Check if it's the first time the script is executed
if [ -d "/root/temp" ]; then
    setup_openmrs
fi

# Start Tomcat
echo "Starting Tomcat..."
$CATALINA_HOME/bin/startup.sh

# Tail Tomcat logs to keep the container running
#tail -f $CATALINA_HOME/logs/catalina.out
