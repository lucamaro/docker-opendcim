#!/bin/bash

VERSION=4.4

cd /var/www
wget -q http://opendcim.org/packages/openDCIM-$VERSION.tar.gz
tar zxpvf openDCIM-$VERSION.tar.gz
ln -s openDCIM-$VERSION dcim
rm openDCIM-$VERSION.tar.gz
rm -R /var/www/html
chgrp -R www-data /var/www/dcim/pictures /var/www/dcim/drawings /var/www/dcim/images

cd /var/www/dcim
cp db.inc.php-dist db.inc.php

# use db from docker link 
sed -i "s/[$]dbhost = [']localhost[']/\$dbhost = 'db'/" /var/www/dcim/db.inc.php

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

# add locales
locale-gen az_AZ
locale-gen ca_AD
locale-gen de_DE
locale-gen es_ES
locale-gen fr_FR
locale-gen gl_ES
locale-gen it_IT
locale-gen ko_KR
locale-gen pt_BR
locale-gen sl_SI
locale-gen uk_UA
locale-gen zh_CN

dpkg-reconfigure locales 

# FIX openDCIM code for locale not working
#sed -i 's:putenv("LC_ALL=$locale");:putenv("LANGUAGE=$locale");:' /var/www/dcim/misc.inc.php
