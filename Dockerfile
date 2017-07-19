FROM php:5-apache
MAINTAINER Luca Maragnani "luca.maragnani@gmail.com"

ARG VERSION=4.4
 
# some	 configuration for apache
COPY apache2.conf /etc/apache2/apache2.conf

# enable localization, see locale-gen below
COPY locale.gen /etc

# Installation of nesesary package/software for this containers...
RUN sed -i 's/jessie\/updates main/jessie\/updates main contrib non-free/' /etc/apt/sources.list && \
    sed -i 's/jessie main/jessie main contrib non-free/' /etc/apt/sources.list &&  \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends \
                    snmp \
                    snmp-mibs-downloader \
                    graphviz \
                    libsnmp-dev \
                    libpng-dev \
                    libjpeg-dev \
                    locales \
                    libldap2-dev \
                    # See https://serverfault.com/questions/633394/php-configure-not-finding-ldap-header-libraries
                    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
                    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
                    && docker-php-ext-install pdo pdo_mysql gettext snmp gd zip ldap \
                    && mkdir -p /var/www && cd /var/www \
                    && wget -q -O - http://opendcim.org/packages/openDCIM-$VERSION.tar.gz | tar xzf - \
                    && mv /var/www/openDCIM-$VERSION /var/www/dcim \
                    && chgrp -R www-data /var/www/dcim/pictures /var/www/dcim/drawings /var/www/dcim/images \
                    && cp /var/www/dcim/db.inc.php-dist /var/www/dcim/db.inc.php \
                    && mkdir /var/www/secure \
                    && htpasswd -cb /var/www/secure/opendcim.password dcim dcim \
                    && a2enmod rewrite \
                    && apt-get remove --auto-remove -y gcc m4 dpkg-dev libc6-dev libgcc-4.9-dev libsnmp-dev \
                    libpcre3-dev linux-libc-dev libldap2-dev libjpeg-dev libpng-dev \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/* \
                    && rm -rf /var/lib/apt/lists/* 

COPY dcim.htaccess /var/www/dcim/.htaccess
COPY 000-default.conf /etc/apache2/sites-available
COPY default-ssl.conf /etc/apache2/sites-available

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 80

# declaration of volumes 
VOLUME ["/var/www/dcim/drawings", "/var/www/dcim/pictures", "/var/www/dcim/images", "/var/www/secure"]

# init script as entrypoint for initial configuration
COPY entrypoint.sh /usr/local/bin
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh", "-DFOREGROUND"]
