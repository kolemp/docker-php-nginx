SHELL = /bin/bash
TAG = "kolemp/docker-php-nginx:$(PHP_VERSION)"

build:
	@if [ "$(PHP_VERSION)" == "" ]; then echo "PHP_VERSION is required"; exit 1; fi;
	docker run --rm -e PHP_VERSION -e WITH_RSYSLOG -v /`pwd`:/data kolemp/twig-renderer /data/Dockerfile.twig > ./Dockerfile
	docker run --rm -e WITH_RSYSLOG -v /`pwd`:/data kolemp/twig-renderer /data/application.conf.twig > ./application.conf
ifeq ($(WITH_RSYSLOG),true)
	docker build -t "$(TAG)-rsyslog" .
else
	docker build -t $(TAG) .
endif