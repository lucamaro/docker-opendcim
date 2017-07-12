#! /bin/sh


if [ ! -f /.configured ] ; then
	# configure port with environment var DBHOST
	sed -i "s/[$]dbhost = [']localhost[']/\$dbhost = '$DBHOST'/" /var/www/dcim/db.inc.php 
	sed -i "s/[$]dbname = [']dcim[']/\$dbname = '$DCIM_DB_SCHEMA'/" /var/www/dcim/db.inc.php 
	sed -i "s/[$]dbuser = [']dcim[']/\$dbuser = '$DCIM_DB_USER'/" /var/www/dcim/db.inc.php 
	sed -i "s/[$]dbpass = [']dcim[']/\$dbpass = '$DCIM_DB_PASSWD'/" /var/www/dcim/db.inc.php 
	sed -i "s/Apache/$DCIM_AUTH/" /var/www/dcim/db.inc.php 
	touch /.configured
fi


exec docker-php-entrypoint "$@"
