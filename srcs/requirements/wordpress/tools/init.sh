#!/bin/bash
set -e

mkdir -p /run/php
chown -R www-data:www-data /run/php /var/www/wordpress

until php -r "new mysqli('mariadb', '${MYSQL_USER}', '${MYSQL_PASSWORD}', '${MYSQL_DATABASE}');" 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done

if [ ! -f "/var/www/wordpress/wp-settings.php" ]; then
    wp core download --path=/var/www/wordpress --allow-root
    wp config create --dbname=${MYSQL_DATABASE} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASSWORD} --dbhost=mariadb --path=/var/www/wordpress --allow-root
    wp core install --url=${DOMAIN_NAME} --title="My WordPress Site" --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASSWORD} --admin_email=${WP_ADMIN_EMAIL} --path=/var/www/wordpress --allow-root
    
fi

exec php-fpm8.2 -F
