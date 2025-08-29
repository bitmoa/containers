# BEGIN WordPress fix for plugins and themes
# Certain WordPress plugins and themes do not properly link to PHP files because of symbolic links
# https://github.com/bitmoa/bitmoa-docker-wordpress-nginx/issues/43
RewriteEngine On
RewriteRule ^bitmoa/wordpress(/.*) $1 [L]
# END WordPress fix for plugins and themes
