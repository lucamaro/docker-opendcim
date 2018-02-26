#! /bin/sh


if [ ! -f /.configured ] ; then
	# configure port with environment var DBHOST
	sed -i "s/[$]dbhost = [']localhost[']/\$dbhost = '$DBHOST'/" /var/www/dcim/db.inc.php 
	sed -i "s/[$]dbname = [']dcim[']/\$dbname = '$DCIM_DB_SCHEMA'/" /var/www/dcim/db.inc.php 
	sed -i "s/[$]dbuser = [']dcim[']/\$dbuser = '$DCIM_DB_USER'/" /var/www/dcim/db.inc.php 
	sed -i "s/[$]dbpass = [']dcim[']/\$dbpass = '$DCIM_DB_PASSWD'/" /var/www/dcim/db.inc.php 

	if [ "$SSL_ON" = "1" ] ; then
		a2enmod ssl
		a2ensite default-ssl
	fi

	# for swarm secret
	if [ -f "$DCIM_PASSWORD_FILE" ] ; then
		PASSWORD=$(cat $DCIM_PASSWORD_FILE)
	elif [ ! -z "$DCIM_PASSWORD" ] ; then
		PASSWORD=$DCIM_PASSWORD
	else
		PASSWORD=dcim
	fi
	htpasswd -cb /data/opendcim.password dcim $PASSWORD

	touch /.configured
fi


exec docker-php-entrypoint "$@"
