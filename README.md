# docker-opendcim container

This was based initially on work of angelrr7702 (thank you for letting me start!). Then it was changed in this parts:

- db was separatend in a different container to achieve one process per container
- layers were reduced in Dockerfile
- backup/restore is done in a more standard way
- starting image was changed to mariadb and php-apache (officials)
- added SSL configuration parameters and tasks
- added LDAP configuration parameters

## Requirements

You need docker installed, obviously. See documentation specific for your OS on docker site.


## Usage

First customize the environment file `dev.env` with the following content:

	DBHOST=dcimdb.yournetwork
	DCIM_DB_SCHEMA=dcim
	DCIM_DB_USER=dcim
	DCIM_DB_PASSWD=changeme
	DCIM_AUTH=Apache

Run image customizing this command

	docker run -d -p 8000:80 \
			--env-file dev.env \
			--name dcim lucamaro/docker-opendcim

Then access for the first time the webapp at http://localhost:8000 with (default credentials: dcim/dcim). 
It displays the installation report that should be correct.

After this you **must** perform after installation procedure:

	docker exec -it dcim rm /var/www/dcim/install.php

Reload the main site page and start enjoying opneDCIM.
	
To change dcim web user credential or to add new users:
	
	docker exec -it dcim htpasswd /var/www/secure/opendcim.password dcim			
	
	
### Optional step: create an empty db
			
If you need a db on the fly you could run a docker image like this:
	
	source dev.env
	docker run --name dcimdb -v /db_backup -e MYSQL_ROOT_PASSWORD=$ROOT_DB_PASSWD -d mariadb

Waiting for db to be up, then:

	docker exec -it dcimdb mysql -uroot -p$ROOT_DB_PASSWD -e "create database $DCIM_DB_SCHEMA"
	docker exec -it dcimdb mysql -uroot -p$ROOT_DB_PASSWD -e "grant all privileges on $DCIM_DB_SCHEMA.* to '$DCIM_DB_USER' identified by '$DCIM_DB_PASSWD'"

Run the dcim web container with a link named db:
	
	docker run -d -p 8000:80 \
			--env-file dev.env \
			--link dcimdb:db \
			--name dcim lucamaro/docker-opendcim
	
### Optional step: use TLS

In order to use TLS, first add to env file the parameter:

	SSL_ON=1

You must run the image with a volume containing certificate and key. Certificate name must be `ssl-cert.pem` and key must be `ssl-cert.key`

	docker run -d -p 8443:443 \
			--env-file dev.env \
			-v $PWD/certs:/etc/ssl/certs \
			--name dcim lucamaro/docker-opendcim

Optionally generate self signed certificates with the following commands:

	mkdir -p certs
	openssl req -x509 -newkey rsa:4096 -keyout certs/ssl-cert.key -out certs/ssl-cert.pem -days 365 -nodes

	
### Optional step: enable LDAP auth

[To be documented]
	
## Updating container

First keep updated this repository:

    docker pull lucamaro/docker-opendcim
    
Execute update in temporary container dcim_next:

	docker stop dcim
	docker run -d -p 8000:80 --env-file dev.txt\
		--volumes-from=dcim \
		--name dcim_next lucamaro/docker-opendcim

Access the new webapp via browser or http client to launch the install.php script, 
then perform the after-install operation on new container:

	docker exec -it dcim rm /var/www/dcim/install.php
    
If everything is ok, delete old container:

	docker rm dcim
	docker rename dcim_next dcim


## Backup containers data

Launch a new container with ``--volumes-from`` directive, then use tar utility to create backup.

    docker run --rm --volumes-from=dcim \
			-v $PWD:/dcim_backup alpine \
			tar cvzf /dcim_backup/dcim_backup.tgz \
					/var/www/dcim/pictures \
					/var/www/dcim/drawings \
					/var/www/dcim/images \
					/var/www/secure \
					/db_backup

Backup archive is in your current dierectory.					
					
If you are using db on docker image as described before:
					
	docker exec -it dcimdb sh -c "mysqldump -uroot -p$(ROOT_DB_PASSWD) --all-databases | gzip -9 > /db_backup/dump.sql.gz"
    docker run --rm --volumes-from=dcim --volumes-from=dcimdb \
			-v $PWD:/dcim_backup alpine \
			tar cvzf /dcim_backup/dcim_backup.tgz \
					/var/www/dcim/pictures \
					/var/www/dcim/drawings \
					/var/www/dcim/images \
					/var/www/secure \
					/db_backup

## Restore db data

[ to be documented ]	
