FROM tomcat:9
# Take the war and copy to webapps of tomcat
#COPY target/*.war /usr/local/tomcat/webapps/dockeransible.war
COPY target/dockeransible-*.war /usr/local/tomcat/webapps/
WORKDIR /usr/local/tomcat/webapps
CMD java -jar dockeransible-*.war
