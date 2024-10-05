# Drupal multisite setup (wamp)

Windows Drupal Site Structure to host multiple websites using same drupal installation. Below are the settings provided for WAMP Server 3.3.5 64

## sites.php (Drupal)

Each domain will point same drupal installation since it's a multi site structure, but will use different database.

```php
$baseDomain = 'example.com';

$subdomains = [
    'dev',
    'stage',
    'uat',
    'www'
];

$sites = [];
foreach ($subdomains as $subdomain) {
    $sites["$subdomain.$baseDomain"] = "$subdomain.$baseDomain";
}
```

## hosts

```shell
127.0.0.1 localhost www.site.com example.com www.example.com dev.example.com stage.example.com uat.example.com
```

## PhpMyAdmin Config Update

```apache
Alias /phpmyadmin "${INSTALL_DIR}/apps/phpmyadmin5.2.1/"

# Default Settings
# ---------------------------------------------------

# <Directory "${INSTALL_DIR}/apps/phpmyadmin5.2.1/">
#   Options +Indexes +FollowSymLinks +MultiViews
#   AllowOverride all
#   Require local
#   # To import big file you can increase values
#   php_admin_value upload_max_filesize 128M
#   php_admin_value post_max_size 128M
#   php_admin_value max_execution_time 360
#   php_admin_value max_input_time 360
# </Directory>

# User Settings
# ---------------------------------------------------

<Directory "${INSTALL_DIR}/apps/phpmyadmin5.2.1/">
 Options +Indexes +FollowSymLinks +MultiViews
 AllowOverride all
 Require all Granted
 # To import big file you can increase values
 php_admin_value post_max_size 128M
 php_admin_value max_input_time 360
 php_admin_value max_input_vars 2000
 php_admin_value default_socket_timeout 60
 php_admin_value memory_limit 1G
 php_admin_value max_execution_time 600
 php_admin_flag output_buffering Off
 php_admin_value upload_max_filesize 512M
 php_admin_value post_max_size 512M
</Directory>
```

## Apache vhost update

```apache
# ----------------------------------------------------------------
# Virtual Hosts
# ----------------------------------------------------------------

<VirtualHost _default_:80>
  ServerName localhost
  ServerAlias localhost
  DocumentRoot "${INSTALL_DIR}/www"
  <Directory "${INSTALL_DIR}/www/">
    Options +Indexes +Includes +FollowSymLinks +MultiViews
    AllowOverride All
    Require local
  </Directory>
</VirtualHost>

<VirtualHost *:80>
  ServerName www.site.com
  ServerAlias www.site.com
  DocumentRoot "${INSTALL_DIR}/www/drupal/web"
  
  <Directory "${INSTALL_DIR}/www/drupal/web/">
      Options FollowSymLinks
      AllowOverride All
      Require all granted
  </Directory>

  # Logging
  ErrorLog "${INSTALL_DIR}/logs/error.log"
  CustomLog "${INSTALL_DIR}/logs/access.log" combined

  # Drupal Performance and Security Settings
  <IfModule mod_rewrite.c>
      RewriteEngine on
      # Redirect www to non-www (optional)
      RewriteCond %{HTTP_HOST} ^www\.(.*)$ [NC]
      RewriteRule ^(.*)$ http://%1/$1 [R=301,L]
  </IfModule>

  <IfModule mod_headers.c>
      # Enable CORS (optional, adjust as needed)
      Header set Access-Control-Allow-Origin "*"
      Header set Access-Control-Allow-Methods "GET,POST,OPTIONS"
      Header set Access-Control-Allow-Headers "DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type"
  </IfModule>

  # Protect files and directories from prying eyes.
  <FilesMatch "\.(engine|inc|info|install|module|profile|po|sh|.*sql|theme|tpl(\.php)?|xtmpl|yml)(~|\.sw[op]|\.bak|\.orig|\.save)?$|^(code-style|entries|install|Makefile|project|robots|translations)\.txt$">
      <IfModule mod_authz_core.c>
          Require all denied
      </IfModule>
      <IfModule !mod_authz_core.c>
          Order allow,deny
          Deny from all
      </IfModule>
  </FilesMatch>

  # PHP Settings (optional)
  php_value memory_limit 256M
  php_value max_execution_time 120
  php_flag display_errors Off
  php_value upload_max_filesize 50M
  php_value post_max_size 50M

  <Directory "${INSTALL_DIR}/www/drupal/web/sites/default/files">
      # Disable script execution for uploads directory
      php_flag engine off
  </Directory>

</VirtualHost>

<VirtualHost *:80>
  ServerName www.example.com
  ServerAlias dev.example.com stage.example.com uat.example.com
  DocumentRoot "${INSTALL_DIR}/www/example/web"
  
  <Directory "${INSTALL_DIR}/www/example/web/">
      Options FollowSymLinks
      AllowOverride All
      Require all granted
  </Directory>

  # Logging
  ErrorLog "${INSTALL_DIR}/logs/error.log"
  CustomLog "${INSTALL_DIR}/logs/access.log" combined

  # Drupal Performance and Security Settings
  <IfModule mod_rewrite.c>
      RewriteEngine on
      # Redirect www to non-www (optional)
      RewriteCond %{HTTP_HOST} ^www\.(.*)$ [NC]
      RewriteRule ^(.*)$ http://%1/$1 [R=301,L]
  </IfModule>

  <IfModule mod_headers.c>
      # Enable CORS (optional, adjust as needed)
      Header set Access-Control-Allow-Origin "*"
      Header set Access-Control-Allow-Methods "GET,POST,OPTIONS"
      Header set Access-Control-Allow-Headers "DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type"
  </IfModule>

  # Protect files and directories from prying eyes.
  <FilesMatch "\.(engine|inc|info|install|module|profile|po|sh|.*sql|theme|tpl(\.php)?|xtmpl|yml)(~|\.sw[op]|\.bak|\.orig|\.save)?$|^(code-style|entries|install|Makefile|project|robots|translations)\.txt$">
      <IfModule mod_authz_core.c>
          Require all denied
      </IfModule>
      <IfModule !mod_authz_core.c>
          Order allow,deny
          Deny from all
      </IfModule>
  </FilesMatch>

  # PHP Settings (optional)
  php_value memory_limit 256M
  php_value max_execution_time 120
  php_flag display_errors Off
  php_value upload_max_filesize 50M
  php_value post_max_size 50M

  <Directory "${INSTALL_DIR}/www/example/web/sites/default/files">
      # Disable script execution for uploads directory
      php_flag engine off
  </Directory>

</VirtualHost>
```

## Custom Error Page

Below are the custom error html template and saved in folder error--pages (E:/wamp64/www/error-pages).

```apache
Alias /error-pages "E:/wamp64/www/error-pages"

<Directory "E:/wamp64/www/error-pages">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

ErrorDocument 401 "/error-pages/401.html"
ErrorDocument 403 "/error-pages/403.html"
ErrorDocument 404 "/error-pages/404.html"
```

## Web Auth Protection

Put below line ine ach project folder .htaccess at the top.

```apache
AuthType Basic
AuthName "Global Access Restricted"
AuthUserFile "E:/wamp_security/.htpasswd"
Require valid-user
```
