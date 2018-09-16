[![CircleCI](https://circleci.com/gh/kolemp/docker-php-nginx/tree/master.svg?style=svg)](https://circleci.com/gh/kolemp/docker-php-nginx/tree/master)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


# PHP for production
This repo is a template to create your production docker image for PHP applications

## PHP info

Supported versions:
- 7.2 
- 7.1
- 7.0 

## Usage
Checkout from [dockerhub](https://hub.docker.com/r/kolemp/docker-php-nginx/tags/).

Default DocumentRoot is `/data/application/`, with index file `index.php`.
You can take it for a spin with creating some simple php file and running:
```bash
docker run --rm -it -p 8090:80 -v /tmp/index.php:/data/application/web/index.php kolemp/docker-php-nginx:7.2
```
But it is mind to be extended and used as a base PHP image for your docker swarm production applications.

### Customisations

You can customize few core configuration variables via env. Here are the variables and their default values:

```bash
PHP_CLI_MEMORY_LIMIT='128M'

PHP_FPM_MEMORY_LIMIT='128M'
PHP_FPM_USER='docker'
PHP_FPM_GROUP='docker'
PHP_FPM_LISTEN='0.0.0.0:9000'
PHP_FPM_PM_MAX_CHILDREN='5'
PHP_FPM_PM_START_SERVERS='2'
PHP_FPM_PM_MIN_SPARE_SERVERS='1'
PHP_FPM_PM_MAX_SPARE_SERVERS='3'
PHP_FPM_REQUEST_TERMINATE_TIMEOUT='0'
```
