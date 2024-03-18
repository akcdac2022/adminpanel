@echo off

REM Define Docker command
set DOCKER=docker-compose run --rm app

REM Define Composer install command
set COMPOSER_INSTALL=%DOCKER% php bin/composer install

REM Define migrate command
set MIGRATE=call .\docker\wait-for-it.bat localhost:33061 8  "%DOCKER% php artisan migrate"

REM Setup target
:setup
docker-compose build
docker-compose up -d --force-recreate
%DOCKER% chmod o+w -R storage bootstrap/cache

REM Copy composer files and set permissions
REM copy composer.json composer.lock /var/www/
%DOCKER% chown -R www-data:www-data /var/www/storage/logs

if not exist bin\composer (
    php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=bin\ --filename=composer
)
%COMPOSER_INSTALL%
if not exist .env (
    copy .env.example .env
    %DOCKER% php artisan key:generate
    REM Set permissions for storage and cache directories
    %DOCKER% chmod -R 777 storage bootstrap/cache
)

REM Add config:cache to cache the configuration
%DOCKER% php artisan config:cache

%MIGRATE%

goto :EOF


REM Up target
:up
docker-compose up -d
%COMPOSER_INSTALL%
%MIGRATE%
goto :EOF

REM Artisan target
:artisan
%DOCKER% php artisan %*

REM Down target
:down
docker rm -f $(docker ps -aq) && docker volume rm `docker volume ls -q`
goto :EOF

REM Tinker target
:tinker
%DOCKER% php artisan tinker
goto :EOF
