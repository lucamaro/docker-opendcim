# This file is part of lucamaro/docker-opendcim

DBPASSWD=changeme
VERSION=4.3
PORT=80

# lists all available targets
list:
	@sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'make\[1\]' | grep -v 'Makefile' | sort"
# required for list
no_targets__:

build:
	@docker build -t lucamaro/docker-opendcim:$(VERSION) .

init:
	@docker run --name dcimdb -e MYSQL_ROOT_PASSWORD=$(DBPASSWD) -d mariadb
	@echo "Waiting for db to be up..."
	@sleep 25
	@docker exec -it dcimdb mysql -uroot -p$(DBPASSWD) -e "create database dcim"
	@docker exec -it dcimdb mysql -uroot -p$(DBPASSWD) -e "grant all privileges on dcim.* to 'dcim' identified by 'dcim'"
	@docker volume create --name dcim_backup
	@docker run -d -p $(PORT):80 --link dcimdb:db -v dcim_backup:/var/backups --name dcim  lucamaro/docker-opendcim:$(VERSION)

update:
	@docker exec -it dcim /sbin/backup
	@docker stop dcim
	@docker run -d -p $(PORT):80 --link dcimdb:db -v dcim_backup:/var/backups --name dcim_next lucamaro/docker-opendcim:$(VERSION)
	@docker exec -it dcim_next /sbin/restore

update-after-install:
	@docker exec -it dcim_next after_install
    
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
	@docker exec -it dcim after_install

stop:
	-@docker stop dcim
	-@docker stop dcimdb

logs:
	@docker exec -it dcim tail -f /var/log/apache2/access_log /var/log/apache2/error.log

