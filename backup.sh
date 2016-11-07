#!/bin/bash

#Backup important file ... of the configuration ...
cp  /etc/hosts  /var/backups/

# create destination directory if they not exists
mkdir -p /var/backups/pictures
mkdir -p /var/backups/drawings
mkdir -p /var/backups/images

#Backup importand files relate to app
cp /var/www/dcim/pictures/* /var/backups/pictures
cp /var/www/dcim/drawings/* /var/backups/drawings
cp /var/www/dcim/images/* /var/backups/images

cp /var/www/opendcim.password /var/backups/
