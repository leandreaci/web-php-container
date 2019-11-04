# Container for php with nginx (Laravel/Lumen Ready)

This is a source to build in your machine the container to run PHP (Laravel) and Nginx.

This container is based on linux alpine container.
- PHP 7.0 : alpine:3.7
- PHP 7.1 > alpine:3.9

# Running php 7.3
`$ git clone https://github.com/leandreaci/web-php-container`

`$ cd web-php-container`

`$ sh build.sh`

# Running other php versions:

### Php 7.0

`$ sh build.sh 7.0`

### Php 7.1

`$ sh build.sh 7.1`

### Php 7.2

`$ sh build.sh 7.2`

### Php 7.3 with oci-8

`$ sh build.sh 7.3-oci8`

# Mapping your laravel/Lumen project to container

`$ cd your_project/`

`docker run -it -p 8000:80 -v $(pwd):/var/www/html php-7.3 /bin/sh`