FROM php:8.3-cli-alpine

WORKDIR /var/www/html

RUN apk add --no-cache \
    git \
    unzip \
    zip \
    libzip-dev \
    oniguruma-dev \
    icu-dev \
    postgresql-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    $PHPIZE_DEPS

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

RUN docker-php-ext-install \
    bcmath \
    exif \
    gd \
    intl \
    mbstring \
    pdo_pgsql \
    zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# نسخ ملفات المشروع أولاً
COPY . .

# تثبيت dependencies بدون تشغيل Laravel scripts أثناء التثبيت
RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --optimize-autoloader \
    --no-scripts

RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache

RUN chmod -R 775 storage bootstrap/cache

ENV PORT=10000

CMD sh -c "php artisan config:cache && php artisan route:cache && php artisan serve --host=0.0.0.0 --port=${PORT}"