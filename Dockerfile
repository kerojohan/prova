#name of container: DSpace_CSUC
#versison of container: 0.1
FROM openjdk:8
MAINTAINER Joan Caparrós  "joan.caparros@csuc.cat"

# Environment variables
ENV TOMCAT_MAJOR=8 TOMCAT_VERSION=8.0.37
ENV TOMCAT_TGZ_URL=https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
ENV MAVEN_TGZ_URL=http://apache.mirror.iweb.ca/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
ENV CATALINA_HOME=/usr/local/tomcat DSPACE_HOME=/dspace
ENV PATH=$CATALINA_HOME/bin:$DSPACE_HOME/bin:$PATH

# Install runtime and dependencies
RUN apt-get update && apt-get install -y git vim ant postgresql-client postgresql


# Making folders and downloads
RUN mkdir -p postgres dspace /projectes/src /projectes/src/dspace
RUN mkdir -p maven dspace "$CATALINA_HOME" \
    && curl -fSL "$TOMCAT_TGZ_URL" -o /tmp/tomcat.tar.gz \
    && curl -fSL "$MAVEN_TGZ_URL" -o /tmp/maven.tar.gz \
    && tar -xvf /tmp/tomcat.tar.gz --strip-components=1 -C "$CATALINA_HOME" \
    && tar -xvf /tmp/maven.tar.gz --strip-components=1  -C maven     \
    && ln -s /maven/bin/mvn /usr/bin/mvn

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8


COPY startup.sh /tmp/
COPY setup-tomcat.sh /tmp/
COPY setup-dspace.sh /tmp/
COPY setup-postgres.sh /tmp/
#conf tomcat7 for dspace
COPY dspace_tomcat8.conf /tmp/dspace_tomcat8.conf

RUN chmod +x /tmp/setup-tomcat.sh \
    && chmod +x /tmp/startup.sh \
    && chmod +x /tmp/setup-tomcat.sh \
    && chmod +x /tmp/setup-dspace.sh \
    && chmod +x /tmp/setup-postgres.sh 


# Start Tomcat
EXPOSE 8080


ENTRYPOINT ["/tmp/startup.sh"]

