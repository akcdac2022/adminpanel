FROM php:7-fpm

# Install required dependencies
RUN apt-get update \
    && apt-get install -y libmcrypt-dev curl zip unzip \
    && docker-php-ext-install mysqli pdo_mysql

WORKDIR /var/www

# Set permissions for Laravel log directory
RUN mkdir -p /var/www/storage/logs \
    && chmod -R 775 /var/www/storage/logs

# Copy composer files and install dependencies
# COPY composer.json composer.lock /var/www/
# RUN composer install --no-scripts --no-autoloader && \
#     rm -rf /var/www/vendor && \
#     composer install --no-scripts

# Copy the rest of the application
COPY . /var/www
