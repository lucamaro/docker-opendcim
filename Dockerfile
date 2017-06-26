FROM php:5.6.30-apache
MAINTAINER Luca Maragnani "luca.maragnani@gmail.com"

ARG VERSION=4.4
 
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
					locales \
                    && docker-php-ext-install pdo pdo_mysql gettext snmp gd zip \
					&& apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/* \
					&& mkdir -p /var/www && cd /var/www \
					&& wget -q -o - http://opendcim.org/packages/openDCIM-$VERSION.tar.gz | tar xf - \
					&& mv openDCIM-$VERSION dcim \
					&& rm -R /var/www/html \
					&& chgrp -R www-data /var/www/dcim/pictures /var/www/dcim/drawings /var/www/dcim/images \
					&& cp /var/www/dcim/db.inc.php-dist /var/www/dcim/db.inc.php \
					&& sed -i "s/[$]dbhost = [']localhost[']/\$dbhost = 'db'/" /var/www/dcim/db.inc.php \
					&& mkdir /var/www/secure \
					&& htpasswd -cb /var/www/secure/opendcim.password dcim dcim \
					&& a2enmod rewrite


#some configuration for apache
COPY apache2.conf /etc/apache2/apache2.conf
RUN sed  -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/dcim/' /etc/apache2/sites-available/000-default.conf

COPY dcim.htaccess /var/www/dcim/.htaccess

# enable localization
COPY locale.gen /etc
RUN locale-gen

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 80

# declaration of volumes 
VOLUME ["/var/www/dcim/drawings", "/var/www/dcim/pictures", "/var/www/dcim/images", "/var/www/secure"]


