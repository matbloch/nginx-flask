# Nginx Reverse Proxy to Flask API

### Getting Started

1. Build the images: `docker-compose build`
2. Start the services: `docker-compose up`
3. Test the static file serving: `curl localhost`
4. Test the reverse proxy to the Flask api: `curl localhost/api/test/route`
5. Shut down the service `docker-compose down`

### Notes

- Both containers need to be in the same network. Docker-compose will add them to a default network `reverse_proxy_default`
- In the Nginx config `proxy/conf/default.conf` the Docker service name, e.g. `api`, can be used to reference the network location of a service inside the same Docker network







