PROJECT=`pwd | xargs basename`
TESTIMAGE=${PROJECT}:testing
USER=nginx

up:
	env UID=$$(id -u) GID=$$(id -g)  docker-compose up --build

down:
	docker-compose down

stop:
	docker-compose stop

sh:
	docker-compose exec --user=${USER} application bash

sh\:db:
	docker-compose exec database bash

setup:
	cp .env.example .env
	env UID=$$(id -u) GID=$$(id -g)  docker-compose up

key\:db:
	echo "Generating key..."
	docker-compose exec --user=${USER} application php artisan key:generate && php artisan config:clear
	echo "Migrating and seeding..."
	docker-compose exec --user=${USER} application php artisan migrate --seed

migrate:
	docker-compose exec --user=${USER} application php artisan migrate

image\:test:
	docker build -f Dockerfile.prod -t ${TESTIMAGE} .
	GOSS_SLEEP=3 dgoss run -i ${TESTIMAGE}