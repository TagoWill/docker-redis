FROM alpine:3.8

LABEL maintainer="contact@tagowill.com"

# For local copy of redis files
COPY ./local_resources/redis-5.0.2.tar.gz /

RUN set -ex \
	\
    && apk update \
    # we dont need all of this. But for now its easier.
    #&& apk add --update alpine-sdk \
    && apk add --no-cache --virtual .build-deps \
        coreutils \
		gcc \
		jemalloc-dev \
		linux-headers \
		make \
		musl-dev \
    \
    # to fix an issue with make file
    #&& apk add linux-headers \
    #\
    # Download via Link
    # && curl -O http://download.redis.io/releases/redis-5.0.0.tar.gz \
    \
    # Unpack the tarball
    && mkdir -p /usr/src/redis \
    && tar xzvf redis-5.0.2.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis-5.0.2.tar.gz \
    # disable Redis protected mode [1] as it is unnecessary in context of Docker
    # (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
    # [1]: https://github.com/antirez/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
	&& grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 1$' /usr/src/redis/src/server.h \
	&& sed -ri 's!^(#define CONFIG_DEFAULT_PROTECTED_MODE) 1$!\1 0!' /usr/src/redis/src/server.h \
	&& grep -q '^#define CONFIG_DEFAULT_PROTECTED_MODE 0$' /usr/src/redis/src/server.h \
    \
	&& make -C /usr/src/redis -j "$(nproc)" \
	&& make -C /usr/src/redis install \
    # && make -C /usr/src/redis test \
	\
	&& rm -r /usr/src/redis \
    # && apk add --virtual .redis-rundeps $runDeps \
	&& apk del .build-deps \
	\
	&& redis-server --version

COPY redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379/tcp

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]