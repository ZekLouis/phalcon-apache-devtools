# Phalcon PHP with DevTools
FROM mileschou/phalcon:7.4-apache

LABEL maintainer="Louis Gaume <zeklouis@gmail.com>"

# Updates and install dependencies
RUN apt-get update -y &&\
    apt-get upgrade -y &&\
    apt-get install -y \
    git \
    libzip-dev \
    nano \
    zip &&\
    docker-php-ext-install zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Phalcon devtools
WORKDIR /home
RUN git clone https://github.com/phalcon/phalcon-devtools.git dev-tools
WORKDIR /home/dev-tools
RUN chmod ugo+x /home/dev-tools/phalcon
RUN echo "alias phalcon=/home/dev-tools/phalcon" >> ~/.bashrc

# Install Phalcon Dependencies with Composer
RUN composer install

COPY ./000-default.conf /etc/apache2/sites-enabled

# Enable mod rewrite
RUN a2enmod rewrite

# CD to the app dir
WORKDIR /var/www