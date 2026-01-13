FROM node:18-alpine AS frontend
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY tailwind.config.js ./
COPY css/app.css ./css/app.css
COPY app/ ./app/
COPY public/ ./public/

RUN mkdir -p ./public/css && \
    npx tailwindcss -i ./css/app.css -o ./public/css/app.css --minify

FROM composer:2.5 AS backend
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

FROM php:8.2-apache-bullseye
WORKDIR /var/www/html

COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite && \
    docker-php-ext-install pdo_mysql

COPY . .
COPY --from=backend /app/vendor/ /var/www/html/vendor/
COPY --from=frontend /app/public/css/app.css /var/www/html/public/css/app.css

RUN chown -R www-data:www-data /var/www/html/storage && \
    chmod -R 775 /var/www/html/storage && \
    rm -rf /var/www/html/docker \
           /var/www/html/tests \
           /var/www/html/README.md \
           /var/www/html/phpunit.xml \
           /var/www/html/ecomotion-web.tar \
           /var/www/html/structure.txt

EXPOSE 80