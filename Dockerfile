FROM php:5.6.30-apache
MAINTAINER Luca Maragnani "luca.maragnani@gmail.com"

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN sed -i 's/jessie\/updates main/jessie\/updates main contrib non-free/' /etc/apt/sources.list && \
	sed -i 's/jessie main/jessie main contrib non-free/' /etc/apt/sources.list &&  \
	apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
					snmp \
                    snmp-mibs-downloader \
                    graphviz \
					libsnmp-dev \
					libpng-dev \
					libjpeg-dev \
                    && docker-php-ext-install pdo pdo_mysql gettext snmp gd zip \
					&& apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*


#some configuration for apache
COPY apache2.conf /etc/apache2/apache2.conf
RUN sed  -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/dcim/' /etc/apache2/sites-available/000-default.conf

#pre-config script for different service that need to be run when container image is create 
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf; sync \
    && /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf
    
##scritp that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convination of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup
COPY restore.sh /sbin/restore
RUN chmod +x /sbin/restore
VOLUME /var/backups

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 80

#creation of volume 
VOLUME /var/www/


