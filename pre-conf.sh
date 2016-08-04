#!/bin/bash

VERSION=4.3

 cd /var/www
 wget http://opendcim.org/packages/openDCIM-$VERSION.tar.gz
 tar zxpvf openDCIM-$VERSION.tar.gz
 ln -s openDCIM-$VERSION dcim
 rm openDCIM-$VERSION.tar.gz
 rm -R /var/www/html
 chgrp -R www-data /var/www/dcim/pictures /var/www/dcim/drawings /var/www/dcim/images
 
 cd /var/www/dcim
 cp db.inc.php-dist db.inc.php
 
 #to fix error relate to ip address of container apache2
 echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
 ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf
 
 #  copy conf of 
 cat << EOF > /var/www/dcim/.htaccess
AuthType Basic
AuthName "openDCIM"
AuthUserFile /var/www/opendcim.password
Require valid-user
EOF
 
 htpasswd -cb /var/www/opendcim.password dcim dcim
 a2enmod rewrite
