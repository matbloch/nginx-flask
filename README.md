# Serving Flask Applications with Nginx

> Flask application, served by Nginx through WSGI (uWSGI), managed by supervisord

### Features

- Configurable `BASIC` authentication: "Basic" HTTP authentication, see [Mozilla Docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#Basic_authentication_scheme)
- User agent blocking (crawlers and search engines)

### Getting Started

**Building**

- `docker build . -t flask_nginx`

**Running the Service**

- Development: `docker run --rm -p 80:80 flask_nginx`

- Deployment (daemon mode): `docker run -d -p 80:80 flask_nginx`

  Configuration

### Configuration

**Nginx Configuration (reverse proxy)**

- Default port is `80`
- `-e LISTEN_PORT='8080'` to change the port
- **Example:** Running Nginx on port `8080 ` and exposing it at port `80` of the host
  -  `docker run -d -p 80:8080 -e LISTEN_PORT='8080' flask_nginx`

**Authentication**

- Enabling authentication:
  - `-e USE_PASSWORD='1'`
- Standard credentials (see `entrypoint.sh`): 
  - username: `default_user`
  - password: `the_password`
- Configuring custom credentials
  - set them through environment variable `HTPASSWD_USERS`
  - use semicolon `;` as separator for different users
  - `-e HTPASSWD_USERS='user1:password1;user2:password2'  `

**Blocking Crawlers**

- Patterns defined in `useragent.rules`

- `- e BLOCK_CRAWLERS='1'`

**Further Configuration**

- See [Documentation of base image](https://github.com/tiangolo/uwsgi-nginx-docker)
- Examples: Number of UWSGI processes, Number of Nginx workers, ...

