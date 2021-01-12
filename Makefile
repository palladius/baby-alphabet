
APPNAME = $(shell basename `pwd`)
VERSION = $(shell cat VERSION)
#SHELL := /bin/bash

up:
	cd k8s && make up
run:
	bundle install
	rails server -b 0.0.0.0 -p 8080

.env:
	cp .env.dist .env
	echo "EDIT AWAY! It wont work unless you do!"
	exit 42

routes:
	rails routes

docker-build:
	echo Entering Docker Build DEBUG for cloud build...
	docker build -t $(APPNAME):v$(VERSION) . -f Dockerfile 
docker-run: docker-build
	docker run -p 8080:8080 -it $(APPNAME):v$(VERSION) make run
docker-run-bash: docker-build
	docker run -p 8080:8080 -it $(APPNAME):v$(VERSION) bash

docker-push-to-gcp: docker-build
	./tag-and-push.sh $(APPNAME) $(VERSION)
	@verde TUTTO OK pushato a balus: $(APPNAME)---$(VERSION)
	make docker-trigger-pull-latest-image

docker-trigger-pull-latest-image:
	@yellow If you want to force K8S to pull latest image Riccardo it suffices for you to kill the pod and it will recreate it. Let me give you the right command bro:
	./kubectl get pods | egrep ^ajalp  | colonna 1  | prepend ./kubectl delete pod/ | lolcat 

cloud-build-locally:
	echo 1. Lets first try with dryrun to check syntatic errors| lolcat
	cloud-build-local .
	echo 2. Lets now do it without dryrun | lolcat
	cloud-build-local --dryrun=false .

run-docker:
	@echo TODO with pure docker, lets use docker composer now.
	# See https://github.com/pacuna/rails5-docker-alpine
	docker-compose build
	#docker-compose run --rm web bin/rails db:create
	docker-compose run --rm web bin/rails db:migrate
	docker-compose up -d

