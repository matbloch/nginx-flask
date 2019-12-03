FROM nginx:1.17.6-alpine

COPY src /usr/share/nginx/html/

RUN rm -rf /etc/nginx/conf.d/default.conf
COPY conf/* /etc/nginx/conf.d/

CMD ["nginx", "-g", "daemon off;", "-c", "/etc/nginx/nginx.conf"]
