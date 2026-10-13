#!/usr/bin/env bash
# Fixes the three things that most commonly break profile-photo uploads on
# the Raya backend server: missing public/storage symlink, wrong ownership
# or mode on storage/, and PHP upload size caps lower than the app allows.
#
# Run on the server:
#   sudo bash deploy/fix-storage.sh
#
# Idempotent — safe to re-run.

set -euo pipefail

APP_DIR="${APP_DIR:-/app/raya_dating_full/backend}"
WEB_USER="${WEB_USER:-www-data}"
PHP_VERSION="${PHP_VERSION:-8.2}"
MAX_UPLOAD="${MAX_UPLOAD:-20M}"

cd "$APP_DIR"

echo "==> Ensuring public/storage symlink exists"
if [ -L public/storage ] && [ -e public/storage ]; then
    echo "    symlink already present and valid"
else
    rm -f public/storage
    sudo -u "$WEB_USER" php artisan storage:link
fi

echo "==> Creating storage subdirectories"
mkdir -p storage/app/public storage/framework/{cache,sessions,views} storage/logs
mkdir -p bootstrap/cache

echo "==> Fixing ownership (${WEB_USER}:${WEB_USER})"
chown -R "${WEB_USER}:${WEB_USER}" storage bootstrap/cache public/storage || true

echo "==> Fixing permissions (775 group-writable)"
find storage -type d -exec chmod 2775 {} \;
find storage -type f -exec chmod 664 {} \;
find bootstrap/cache -type d -exec chmod 2775 {} \;
find bootstrap/cache -type f -exec chmod 664 {} \;

echo "==> Raising PHP upload limits to ${MAX_UPLOAD}"
for ini in "/etc/php/${PHP_VERSION}/fpm/php.ini" "/etc/php/${PHP_VERSION}/cli/php.ini"; do
    [ -f "$ini" ] || continue
    sed -ri "s/^(upload_max_filesize)\s*=.*/\1 = ${MAX_UPLOAD}/" "$ini"
    sed -ri "s/^(post_max_size)\s*=.*/\1 = ${MAX_UPLOAD}/" "$ini"
    sed -ri "s/^(memory_limit)\s*=.*/\1 = 256M/" "$ini"
    echo "    patched $ini"
done

echo "==> Reloading PHP-FPM and nginx"
systemctl reload "php${PHP_VERSION}-fpm" || systemctl restart "php${PHP_VERSION}-fpm"
nginx -t && systemctl reload nginx

echo "==> Clearing Laravel caches so new APP_URL/perms take effect"
sudo -u "$WEB_USER" php artisan config:clear
sudo -u "$WEB_USER" php artisan cache:clear

APP_URL_VALUE="$(grep -E '^APP_URL=' .env | cut -d= -f2- | tr -d '"')"
echo "==> APP_URL currently: ${APP_URL_VALUE}"
if [[ "$APP_URL_VALUE" != https://* ]]; then
    echo "    WARNING: Flutter client talks to https://kingdom-dating.co.ke/api — public"
    echo "    photo URLs are built from APP_URL, so set it to the HTTPS domain or"
    echo "    uploaded images will be unreachable from release builds."
fi

echo "==> Done. Verify a known uploaded path returns 200:"
echo "    curl -I \"${APP_URL_VALUE}/storage/\""
