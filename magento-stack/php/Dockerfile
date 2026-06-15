# Stage 1: Composer Installer Binary Extraction
FROM php:8.3-fpm-bookworm AS composer_base

# Stage 2: Final Runtime Image
FROM php:8.3-fpm-bookworm

# Install required system packages for Magento 2 extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    libxslt1-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Configure and install Magento required PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    gd \
    intl \
    pdo_mysql \
    soap \
    sockets \
    xsl \
    zip \
    opcache \
    ftp

# Pull official Composer binary straight into this runtime image
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
