# Use the tomcat:9.0.85-jdk8 base image
FROM tomcat:9.0.85-jdk8

ENV OPENMRS_HOME /root/.OpenMRS
ENV OPENMRS_MODULES ${OPENMRS_HOME}/modules
# ENV OPENMRS_PLATFORM_URL="https://nofile.io/f/TvXKVtdVjOX/openmrs.war"
# ENV OPENMRS_REST_URL="https://modules.openmrs.org/modulus/api/releases/1616/download/webservices.rest-2.20.0.omod"

ENV DB_NAME="openmrs"
ENV OPENMRS_DB_USER=""
ENV OPENMRS_DB_PASS=""
ENV OPENMRS_MYSQL_HOST=""
ENV OPENMRS_MYSQL_PORT=""
ENV OPENMRS_NAME=""
# Refresh repositories and add mysql-client and libxml2-utils (for xmllint)
# Download and Deploy OpenMRS
# Download and copy reference application modules (if defined)
# Unzip modules and copy to module/ref folder
# Create database and setup openmrs db user
COPY openmrs.war /root/temp/
RUN mkdir -p ${OPENMRS_HOME}
# Add the following lines to update the sources.list
# Update sources.list to use the archive.debian.org URL

# Install additional packages
RUN apt-get update && apt-get install -y mysql-client

 
ENV TZ=Africa/Nairobi
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata
RUN echo "cron.* /var/log/cron.log" >> /etc/rsyslog.conf
ADD modules /root/temp/modules/
#Copy OpenMRS properties file
COPY openmrs-runtime.properties /root/temp/
#COPY ./InvalidateHTTPSessions InvalidateHTTPSessions
COPY ./ScheduledGC ScheduledGC
EXPOSE 8080
# Add microfrontend assets
ADD microfrontends /root/temp/microfrontends
# Add spa frontend assets
ADD microfrontends /root/temp/frontend
# Setup openmrs, optionally load demo data, and start tomcat

COPY run.sh /usr/local/tomcat/bin/run.sh
RUN chmod +x /usr/local/tomcat/bin/run.sh

# Execute the run script
CMD ["sh", "/usr/local/tomcat/bin/run.sh"]