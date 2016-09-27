# This file is part of lucamaro/docker-opendcim

DBPASSWD=changeme

# lists all available targets
list:
	@sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'make\[1\]' | grep -v 'Makefile' | sort"
# required for list
no_targets__:

build:
	@docker build -t lucamaro/docker-opendcim:4.3 .

run:
	@docker run --name dcimdb -e MYSQL_ROOT_PASSWORD=$(DBPASSWD) -d mariadb
	@echo "Waiting for db to be up..."
	@sleep 25
	@docker exec -i dcimdb mysql -uroot -p$(DBPASSWD) < prepare_db.sql
	@docker run -d -p 80:80 --link dcimdb:db --name dcim  lucamaro/docker-opendcim:4.3

start:
	-@docker start dcimdb dcim

after-install:
	@docker exec -it dcim after_install

stop:
	-@docker stop dcim
	-@docker stop dcimdb

logs:
	@docker exec -it dcim tail -f /var/log/apache2/access_log /var/log/apache2/error.log

