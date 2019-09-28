FROM tiangolo/uwsgi-nginx:python3.7
MAINTAINER M.B.

## ---- Installation of requirements

RUN apt-get update && \
    apt-get install --no-install-recommends -y apache2-utils && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the python requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip \
    && pip install -r /tmp/requirements.txt

## ---- Nginx configuration

# Select the custom uwsgi configuration file
ENV UWSGI_INI /web/uwsgi.ini

# Nginx port
ENV LISTEN_PORT 80
EXPOSE 80

# Block crawlers and search engines
ENV BLOCK_CRAWLERS 0

# Configure password protection
ENV USE_PASSWORD 1
# Define users. Separate them using ";"
# e.g. "user_1:pwd1;user_2:pwd2"
ENV HTPASSWD_USERS "default_user:the_password"

# By default, allow unlimited file sizes, modify it to limit the file sizes
# To have a maximum of 1 MB (Nginx's default) change the line to:
# ENV NGINX_MAX_UPLOAD 1m
ENV NGINX_MAX_UPLOAD 0

# URL under which static (not modified by Python) files will be requested
# They will be served by Nginx directly, without being handled by uWSGI
ENV STATIC_URL /static
# Absolute path to the static files
ENV STATIC_PATH /web/app/static

# Copy the entrypoint that will generate the additional Nginx configs
RUN mv /entrypoint.sh /uwsgi-nginx-entrypoint.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Copy a list of agents to block through Nginx (such as search engine crawlers)
COPY useragent.rules /etc/nginx/useragent.rules

## ---- Copy and run the application

# Copy the web application
COPY ./web /web
WORKDIR /web

# Run the start script provided by the parent image tiangolo/uwsgi-nginx.
# It will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Supervisor, which in turn will start Nginx and uWSGI
CMD ["/start.sh"]