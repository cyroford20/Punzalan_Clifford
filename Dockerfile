FROM php:8.0-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy existing application directory contents
COPY . /var/www/html

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www/html

# Install composer dependencies
RUN composer install --no-dev --optimize-autoloader

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html/runtime/sessions \
    && mkdir -p /var/www/html/runtime/cache \
    && mkdir -p /var/www/html/runtime/logs \
    && chown -R www-data:www-data /var/www/html/runtime \
    && chmod -R 755 /var/www/html/runtime

# Create session directory with proper permissions
RUN mkdir -p /tmp/sessions \
    && chown -R www-data:www-data /tmp/sessions \
    && chmod -R 755 /tmp/sessions

# Change current user to www
USER www-data

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
