#! /usr/bin/env bash
set -e

/uwsgi-nginx-entrypoint.sh

create_htpasswd ()
{
    htpasswd -bc /etc/nginx/conf.d/.htpasswd "$1" "$2"
}

add_user ()
{
    htpasswd -b /etc/nginx/conf.d/.htpasswd "$1" "$2"
}

# Get the maximum upload file size for Nginx, default to 0: unlimited
USE_NGINX_MAX_UPLOAD=${NGINX_MAX_UPLOAD:-0}
# Generate Nginx config for maximum upload file size
echo "client_max_body_size $USE_NGINX_MAX_UPLOAD;" > /etc/nginx/conf.d/upload.conf

# Get the URL for static files from the environment variable
USE_STATIC_URL=${STATIC_URL:-'/static'}
# Get the absolute path of the static files from the environment variable
USE_STATIC_PATH=${STATIC_PATH:-'/web/app/static'}
# Get the listen port for Nginx, default to 80
USE_LISTEN_PORT=${LISTEN_PORT:-80}

# Generate Nginx config first part using the environment variables
echo "
    include /etc/nginx/useragent.rules;
    server {
    listen ${USE_LISTEN_PORT};
	keepalive_timeout 0;
    location / {
        try_files \$uri @app;
		proxy_read_timeout 300;
		proxy_connect_timeout 300;
		proxy_request_buffering off;
		proxy_buffering off;
    }
    location @app {
        include uwsgi_params;
        uwsgi_pass unix:///tmp/uwsgi.sock;
    }
    location $USE_STATIC_URL {
        alias $USE_STATIC_PATH;
    }" > /etc/nginx/conf.d/nginx.conf
	
# Blow web crawlers and search engines
if [[ $BLOCK_CRAWLERS == 1 ]] ; then 
echo "if (\$badagent) {
        return 444;
	  " >> /etc/nginx/conf.d/nginx.conf
fi
	
if [[ $USE_PASSWORD == 1 ]] ; then 
echo "auth_basic           	'Restricted Access!';
      auth_basic_user_file 	/etc/nginx/conf.d/.htpasswd; " >> /etc/nginx/conf.d/nginx.conf
fi
	
# If STATIC_INDEX is 1, serve / with /static/index.html directly (or the static URL configured)
if [[ $STATIC_INDEX == 1 ]] ; then 
echo "    location = / {
        index $USE_STATIC_URL/index.html;
    }" >> /etc/nginx/conf.d/nginx.conf
fi
# Finish the Nginx config file
echo "}" >> /etc/nginx/conf.d/nginx.conf


if [[ $USE_PASSWORD == 1 ]] ; then 
# generate htpasswd. Default user/password: "default_user"/"the_password"
HTPASSWD_USERS=${HTPASSWD_USERS:-'default_user:the_password'}
set -f  # avoid globbing (expansion of *).
logins=(${HTPASSWD_USERS//;/ })
for i in "${!logins[@]}"
do
	login=(${logins[i]//:/ })
	if [ ! -f /etc/nginx/conf.d/.htpasswd ]; then
		create_htpasswd ${login[0]} ${login[1]}
	else
		add_user ${login[0]} ${login[1]}
	fi
done
fi

exec "$@"