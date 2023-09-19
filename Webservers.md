# Web Server and Project Settings

## Project user and owner
By default `nginx` uses "www-data" user for the website and application;
it is also the same user name that was used by the server of `Apache`.

```shell
# first check web server user for nginx or apache
ps aux | grep nginx

# see above command showing below result that the nginx service is running using
# www-data user; hence folder owner should also be www-data. However you can change
# the nginx and project folder owner as per your requirement.

ubuntu@webserver-01:~$ ps aux | grep nginx
root      374877  0.0  0.0  52092  6248 ?        Ss   Sep13   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data  440268  0.0  0.0  52744  6596 ?        S    Sep18   0:01 nginx: worker process
www-data  440269  0.0  0.0  52744  6596 ?        S    Sep18   0:00 nginx: worker process
ubuntu  443459  0.0  0.0   8164   596 pts/0    R+   07:17   0:00 grep --color=auto nginx

# you can check same fpr apache or httpd
ps aux | grep apache
ps aux | grep httpd

# check user for php and php-fpm
ps aux | grep php
ps aux | grep fpm

# see above command showing below result that the php or php-fpm service is running using www-data user;
# hence folder owner should also be www-data. However you can change the nginx and project
# folder owner as per your requirement.

ubuntu@webserver-01:~$ ps aux | grep php
root       33984  0.0  0.2 216120 16640 ?        Ss   Jul11   8:51 php-fpm: master process (/etc/php/8.0/fpm/php-fpm.conf)
www-data  176179  0.0  0.7 297660 64984 ?        S    Aug08   0:38 php-fpm: pool www
www-data  368776  0.0  0.8 298648 67360 ?        S    Sep12   0:14 php-fpm: pool www
www-data  368777  0.0  0.8 297060 67548 ?        S    Sep12   0:20 php-fpm: pool www
ubuntu  443468  0.0  0.0   8164  2464 pts/0    S+   07:23   0:00 grep --color=auto php
```

## See the web server user Nginx

To check which user has been set by Nginx as default you need to first verify that the nginx is installed using below commands.

```shell
# check if nginx is installed and available as a command
ubuntu@webserver-01:~$ which nginx
/usr/sbin/nginx

# check nginx version
ubuntu@webserver-01:~$ nginx -v
nginx version: nginx/1.18.0 (Ubuntu)

# you can also combine the which and other command
ubuntu@webserver-01:~$ $(which nginx) -v
nginx version: nginx/1.18.0 (Ubuntu)

# to check the nginx config path see the config file path '--conf-path' and open it
ubuntu@webserver-01:~$ $(which nginx) -V

nginx version: nginx/1.18.0 (Ubuntu)
built with OpenSSL 1.1.1f  31 Mar 2020
TLS SNI support enabled
configure arguments: --with-cc-opt='-g -O2 -fdebug-prefix-map=/build/nginx-BUo7Uw/nginx-1.18.0=. -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_sub_module

# open the nginx default config file
vi /etc/nginx/nginx.conf

# you will see below similar output

user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

# here 'user' is user to assign to run the nginx. Now press the esc and :q! to exit from vi editor

# now if you want to see the php-fpm user then you can follow the below steps

# lets find the php-fpm process to verify if the php-fpm service is running

ubuntu@webserver-01:~$ ps aux | grep php-fpm
root       33984  0.0  0.2 216120 16640 ?        Ss   Jul11   8:51 php-fpm: master process (/etc/php/8.0/fpm/php-fpm.conf)
www-data  176179  0.0  0.7 297660 64984 ?        S    Aug08   0:38 php-fpm: pool www
www-data  368776  0.0  0.8 298648 67360 ?        S    Sep12   0:14 php-fpm: pool www
www-data  368777  0.0  0.8 297060 67548 ?        S    Sep12   0:20 php-fpm: pool www
neesingh  443552  0.0  0.0   8164   656 pts/0    R+   07:39   0:00 grep --color=auto php-fpm

# this is the output if php-fpm service is running and we can see a
# path /etc/php/8.0/fpm/php-fpm.conf is there which is fpm config to manage the settings,
# open it to see the other config ad user details.

vi /etc/php/8.0/fpm/php-fpm.conf

# once you will open the file below kind of output you will see.

# ;;;;;;;;;;;;;;;;;;;;;
# ; FPM Configuration ;
# ;;;;;;;;;;;;;;;;;;;;;
# 
# ; All relative paths in this configuration file are relative to PHP's install
# ; prefix (/usr). This prefix can be dynamically changed by using the
# ; '-p' argument from the command line.

# ;;;;;;;;;;;;;;;;;;;;
# ; Pool Definitions ;
# ;;;;;;;;;;;;;;;;;;;;
# 
# ; Multiple pools of child processes may be started with different listening
# ; ports and different management options.  The name of the pool will be
# ; used in logs and stats. There is no limitation on the number of pools which
# ; FPM can handle. Your system will tell you anyway :)
# 
# ; Include one or more files. If glob(3) exists, it is used to include a bunch of
# ; files from a glob(3) pattern. This directive can be used everywhere in the
# ; file.
# ; Relative path can also be used. They will be prefixed by:
# ;  - the global prefix if it's been set (-p argument)
# ;  - /usr otherwise
# include=/etc/php/8.0/fpm/pool.d/*.conf

# in Pool Definitions section you can see there are other config files
# which are included here - include=/etc/php/8.0/fpm/pool.d/*.conf
# Now ls -la the path

ls -la include=/etc/php/8.0/fpm/pool.d/

drwxr-xr-x 2 root root  4096 Jun 24 09:14 .
drwxr-xr-x 4 root root  4096 Jun 29 11:01 ..
-rw-r--r-- 1 root root 20543 Jun  8 15:24 www.conf

# notice the www.conf file which is master config for pool open it to see users
vi /etc/php/8.0/fpm/pool.d/www.conf

# ; Unix user/group of processes
# ; Note: The user is mandatory. If the group is not set, the default user's group
# ;       will be used.
# user = www-data
# group = www-data
# 
# ; The address on which to accept FastCGI requests.
# ; Valid syntaxes are:
# ;   'ip.add.re.ss:port'    - to listen on a TCP socket to a specific IPv4 address on
# ;                            a specific port;
# ;   '[ip:6:addr:ess]:port' - to listen on a TCP socket to a specific IPv6 address on
# ;                            a specific port;
# ;   'port'                 - to listen on a TCP socket to all addresses
# ;                            (IPv6 and IPv4-mapped) on a specific port;
# ;   '/path/to/unix/socket' - to listen on a unix socket.
# ; Note: This value is mandatory.
# listen = /run/php/php8.0-fpm.sock
# 
# ; Set listen(2) backlog.
# ; Default Value: 511 (-1 on FreeBSD and OpenBSD)
# ;listen.backlog = 511
# 
# ; Set permissions for unix socket, if one is used. In Linux, read/write
# ; permissions must be set in order to allow connections from a web server. Many
# ; BSD-derived systems allow connections regardless of permissions. The owner
# ; and group can be specified either by name or by their numeric IDs.
# ; Default Values: user and group are set as the running user
# ;                 mode is set to 0660
# listen.owner = www-data
# listen.group = www-data
# ;listen.mode = 0660
# ; When POSIX Access Control Lists are supported you can set them using
# ; these options, value is a comma separated list of user/group names.
# ; When set, listen.owner and listen.group are ignored
# ;listen.acl_users =
# ;listen.acl_groups =

# notice the user and group you will see same www-data, you can also see the listen and listen.owner.
# Here listen 'listen =' can be use in nginx to forward the php request to fpm socket.
# Hence make sure your project folder has right owner and group to make sure web server
# and other services can read and write the files and folders.
```
