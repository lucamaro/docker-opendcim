#!/bin/bash


#Restore importand files relate to app
cp /var/backups/pictures/* /var/www/dcim/pictures
cp /var/backups/drawings/* /var/www/dcim/drawings 
cp /var/backups/images/* /var/www/dcim/images 

cp /var/backups/opendcim.password /var/www/ 

chgrp -R www-data /var/www/dcim/pictures /var/www/dcim/drawings /var/www/dcim/images

