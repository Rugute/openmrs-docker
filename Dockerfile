# Use the tomcat:9.0.85-jdk8 base image
FROM tomcat:9.0.85-jdk8

# Set environment variables
ENV OPENMRS_HOME /root/.OpenMRS
ENV OPENMRS_MODULES ${OPENMRS_HOME}/modules
ENV DB_NAME="openmrs"
ENV OPENMRS_DB_USER=""
ENV OPENMRS_DB_PASS=""
ENV OPENMRS_MYSQL_HOST=""
ENV OPENMRS_MYSQL_PORT=""
ENV OPENMRS_NAME=""

# Install additional packages
RUN apt-get update && apt-get install -y mysql-client

# Set timezone
ENV TZ=Africa/Nairobi
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Copy OpenMRS properties file, modules, and microfrontends
COPY openmrs.war /root/temp/
COPY modules /root/temp/modules/
COPY microfrontends /root/temp/microfrontends/
COPY openmrs-runtime.properties /root/temp/



# Copy the WAR file from the local filesystem into the Tomcat webapps directory
#COPY openmrs.war /usr/local/tomcat/webapps/
# Copy custom run script
COPY run.sh /usr/local/tomcat/bin/run.sh
RUN chmod +x /usr/local/tomcat/bin/run.sh

# Expose Tomcat port
EXPOSE 8080

#COPY run.sh /run.sh
#ENTRYPOINT ["/run.sh"]
# Start Tomcat when the container starts
#CMD ["/usr/local/tomcat/bin/run.sh"]
#CMD ["/usr/local/tomcat/bin/run.sh"]

# Execute the run script
CMD ["sh", "/usr/local/tomcat/bin/run.sh"]