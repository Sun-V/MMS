FROM daocloud.io/library/tomcat:8.5.20-jre8-alpine

COPY target/*.war /usr/local/tomcat/webapps/
