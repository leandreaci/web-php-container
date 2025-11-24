# Container for php with nginx (Laravel/Lumen Ready)

This is a source to build in your machine the container to run PHP (Laravel) and Nginx.

This container is based on linux alpine container.

# Running php 8.5
`$ git clone https://github.com/leandreaci/web-php-container`

`$ cd web-php-container`

`$ sh build.sh`

# Running other php versions:

### Php 8.1

`$ sh build.sh 8.1`

### Php 8.1 with oracle

`$ sh build.sh 8.1-oci8`


# Mapping your laravel/Lumen project to container

`$ cd your_project/`

`docker run -it -p 8000:80 -v $(pwd):/var/www/html php-8.5 /bin/sh`