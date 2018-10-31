FROM redis:5.0.0

COPY redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379/tcp

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]