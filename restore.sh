#!/bin/bash


#Restore importand files relate to app
cp -R /var/backups/pictures /var/www/dcim/pictures
cp -R /var/backups/drawings /var/www/dcim/drawings 
cp -R /var/backups/images /var/www/dcim/images 

cp /var/backups/opendcim.password /var/www/ 

chgrp -R www-data /var/www/dcim/pictures /var/www/dcim/drawings /var/www/dcim/images

