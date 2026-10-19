FROM ghcr.io/nginxinc/nginx-unprivileged:1.27-alpine-slim

USER root

ARG BUILD_SHA=local

COPY app/nginx.conf /etc/nginx/nginx.conf
COPY app/index.html /usr/share/nginx/html/index.html

RUN sed -i "s/__BUILD_SHA__/${BUILD_SHA}/g" /usr/share/nginx/html/index.html

USER nginx

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
