
APPNAME = $(shell basename `pwd`)
VERSION = $(shell cat VERSION)
PWD = $(shell pwd)
#SHELL := /bin/bash


deps: package.json
	echo Resolving dependencies like yarn

package.json: 
	echo Whollalla YARN hasnt run lets fix that
	rake assets:precompile
	echo This should fix it hopefully 

up:
	cd k8s && make up
run: # test
	bundle install
	rails server -b 0.0.0.0 -p 8080

.env:
	cp .env.dist .env
	echo "EDIT AWAY! It wont work unless you do!"
	exit 42

routes:
	rails routes

docker-build: test deps
	@echo [make docker-build] Entering Docker Build DEBUG for cloud build... | lolcat
	docker build -t $(APPNAME):v$(VERSION) . -f Dockerfile 

#############################################################################################
# run a static version of the container: efficient, self contained but you cant develop on it
docker-run: docker-build
	docker run -p 8080:8080 -it $(APPNAME):v$(VERSION) make run
docker-run-bash: docker-build
	docker run -p 8080:8080 -it $(APPNAME):v$(VERSION) bash
#############################################################################################

#############################################################################################
# run a mounted volume version of the container: more error prone as you have the static
# stuff with mounted upon it the dynamic stuff, but HEY! If you chaneg the code, it runs on dev
#Amazing stuff...
#docker-runvol: docker-build
#	docker run -p 8080:8080 -it $(APPNAME):v$(VERSION) make run
docker-runvol-bash: docker-build
	docker run -p 8080:8080 -v $(PWD):/myapp -it $(APPNAME):v$(VERSION) bash
#############################################################################################


docker-push-to-gcp: docker-build
	./tag-and-push.sh $(APPNAME) $(VERSION)
	@verde TUTTO OK pushato a balus: $(APPNAME)---$(VERSION)
	make docker-trigger-pull-latest-image

docker-trigger-pull-latest-image:
	@yellow If you want to force K8S to pull latest image Riccardo it suffices for you to kill the pod and it will recreate it. Let me give you the right command bro:
	./kubectl get pods | egrep ^ajalp  | colonna 1  | prepend ./kubectl delete pod/  | lolcat 

cloud-build-locally:
	echo 1. Lets first try with dryrun to check syntatic errors| lolcat
	cloud-build-local .
	echo 2. Lets now do it without dryrun | lolcat
	cloud-build-local --dryrun=false .

git-push: test
	git push

run-docker:
	@echo TODO with pure docker, lets use docker composer now.
	# See https://github.com/pacuna/rails5-docker-alpine
	docker-compose build
	#docker-compose run --rm web bin/rails db:create
	docker-compose run --rm web bin/rails db:migrate
	docker-compose up -d

test: check-conflicts
# fix these: https://stackoverflow.com/questions/41154015/how-to-prevent-git-from-committing-two-files-with-names-differing-only-in-case
# -L = --files-without-match
# https://unix.stackexchange.com/questions/330660/prevent-grep-from-exiting-in-case-of-nomatch
#it works! echo alphabeto | { grep alphabet && exit 42 ||  :; }
check-conflicts:
	@echo [make check-conflicts] BEGIN | lolcat
	find app/assets/ | sort -f | uniq -di | lolcat
	@echo If you see some output then youre screwed. do NOT commit my friend. This check should exit with value 41 anyway. Make sure you push with make git-push to preserve yourself from this behaviour.
	find app/assets/ | sort -f | uniq -di | { grep alphabet && exit 41 ||  :; }
	verde Check OK no duplicates in app/assets
