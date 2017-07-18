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

**First customize DBPASS, DCIMDBPASSWD and PORT variable in Makefile.**

If you want to use SSL, customize SSL parameters in Makefile. Optionally use 
the task `generate-certs` to generate self signed certificates in the correct 
ezpected by volume option (see Makefile init_dcim task).

To run db container **only for the first time**,  use the command below:

    $ make init_db

This will create dcimdb (mariadb instance).

Run dcim container:

    $ make init_dcim

## Accessing the opendcim applications:

After that check with your browser at addresses:

  - **http://host_ip/**

Log in using login/password dcim/dcim  please replace it after initial web install with command :

    $ make after-install
    
This will ask for new password for dcim user and it will remove the install script for security.

To access the container from the server that the container is running :

    $ docker exec -it dcim /bin/bash
    $ docker exec -it dcimdb /bin/bash


## Updating container

First keep updated this repository:

    $ docker pull lucamaro/opendcim-4.4:latest
    
Execute update in temporary container dcim_next:

    $ make update

Access the new webapp via browser or http client to launch the install.php script, 
then perform the after-install operation on new container:

    $ make update-after-install
    
If everything is ok, delete old container:

    $ make confirm_update

else...

    $ make undo_update

## Backup containers data

Launch a new container with ``--volumes-from`` directive, then use tar utility to create backup.

    $ docker run --rm --volumes-from=dcim --volumes-from=dcimdb \
			-v $PWD:/dcim_backup alpine \
			tar cvzf /dcim_backup/dcim_backup.tgz \
					/var/www/dcim/pictures \
					/var/www/dcim/drawings \
					/var/www/dcim/images \
					/var/www/secure \
					/db_backup

## Restore db data

Retrieve dump.sql.gz from the backup created above, then:

	make restore_db
	
