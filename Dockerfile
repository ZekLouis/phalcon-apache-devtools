# Phalcon PHP with DevTools
FROM php:7.3-apache

LABEL maintainer="Louis Gaume <zeklouis@gmail.com>"

ARG PHALCON_VERSION=3.4.5
ARG PHALCON_EXT_PATH=php7/64bits

RUN set -xe && \
        # Compile Phalcon
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PHALCON_VERSION}.tar.gz && \
        docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) ${PWD}/cphalcon-${PHALCON_VERSION}/build/${PHALCON_EXT_PATH} && \
        # Remove all temp files
        rm -r \
            ${PWD}/v${PHALCON_VERSION}.tar.gz \
            ${PWD}/cphalcon-${PHALCON_VERSION}

# Updates and install dependencies
RUN apt-get update -y &&\
    apt-get upgrade -y &&\
    apt-get install -y \
    git \
    libzip-dev \
    nano \
    zlibc \
    zip &&\
    docker-php-ext-install zip mysqli pdo pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Phalcon devtools
WORKDIR /home
RUN git clone https://github.com/phalcon/phalcon-devtools.git dev-tools
WORKDIR /home/dev-tools
RUN git checkout 3.4.x
RUN chmod ugo+x /home/dev-tools/phalcon
RUN echo "alias phalcon=/home/dev-tools/phalcon" >> ~/.bashrc

# Install Phalcon Dependencies with Composer
RUN composer install

COPY ./000-default.conf /etc/apache2/sites-enabled

# Enable mod rewrite
RUN a2enmod rewrite

# CD to the app dir
WORKDIR /var/www