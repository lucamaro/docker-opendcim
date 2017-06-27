# This file is part of lucamaro/docker-opendcim

## CUSTOMIZED VARIABLES
# root password for mysql
DBPASSWD=changeme
# schema owner password
DCIMDBPASSWD=changeme
# port exposing the service by your container
PORT=80

## don't change this
VERSION=4.4


# lists all available targets
list:
	@sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'make\[1\]' | grep -v 'Makefile' | sort"
# required for list
no_targets__:

build:
	@docker build -t lucamaro/docker-opendcim:$(VERSION) .

init_db:
	@docker run --name dcimdb -v /db_backup -e MYSQL_ROOT_PASSWORD=$(DBPASSWD) -d mariadb
	@echo "Waiting for db to be up..."
	@sleep 25
	@docker exec -it dcimdb mysql -uroot -p$(DBPASSWD) -e "create database dcim"
	@docker exec -it dcimdb mysql -uroot -p$(DBPASSWD) -e "grant all privileges on dcim.* to 'dcim' identified by '$(DCIMDBPASSWD)'"

backup_db:
	@docker exec -it dcimdb sh -c "mysqldump -uroot -p$(DBPASSWD) --all-databases | gzip -9 > /db_backup/dump.sql.gz"

restore_db:
	 @$(shell zcat dump.sql.gz | docker exec -i dcimdb mysql -uroot -p$(DBPASSWD))
	
init_dcim:
	@docker run -d -p $(PORT):80 --link dcimdb:db --name dcim  lucamaro/docker-opendcim:$(VERSION)

update:
	@docker stop dcim
	@docker run -d -p $(PORT):80 --link dcimdb:db --name dcim_next lucamaro/docker-opendcim:$(VERSION)

update-after-install:
	@docker exec -it dcim_next rm /var/www/dcim/install.php
    
undo_update:
	-@docker stop dcim_next
	-@docker rm -v dcim_next
	@docker start dcim

confirm_update:
	@docker rm -v dcim
	@docker rename dcim_next dcim

start:
	-@docker start dcimdb dcim

after-install:
	@docker exec -it dcim rm /var/www/dcim/install.php
	$(info Change dcim password...)
	@docker exec -it dcim htpasswd /var/www/secure/opendcim.password dcim

stop:
	-@docker stop dcim
	-@docker stop dcimdb

logs:
	@docker logs dcim
