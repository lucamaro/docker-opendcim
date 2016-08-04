#!/bin/bash

#Backup important file ... of the configuration ...
cp  /etc/hosts  /var/backups/

#Backup importand files relate to app
cp -R /var/www/dcim/pictures /var/backups/pictures
cp -R /var/www/dcim/drawings /var/backups/drawings
cp -R /var/www/dcim/images /var/backups/images
