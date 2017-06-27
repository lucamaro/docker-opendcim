#! /bin/sh


if [ ! -f /.configured ] ; then
	# configure port with environment var DBHOST
	sed -i "s/[$]dbhost = [']localhost[']/\$dbhost = '$(DBHOST)'/" /var/www/dcim/db.inc.php 
	touch /.configured
fi


exec docker-php-entrypoint
