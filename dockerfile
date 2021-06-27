FROM alpine as builder

# build
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base linux-headers git

RUN git clone https://github.com/zfl9/chinadns-ng /tmp/chinadns-ng
# RUN git clone https://hub.fastgit.org/zfl9/chinadns-ng /tmp/chinadns-ng

RUN cd /tmp/chinadns-ng \
  && make -j$(nproc) CFLAGS="-O3 -pipe" \
  && make install DESTDIR="/app" \
  && make clean \
  && cd / \
  && rm -r /tmp/chinadns-ng \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add --no-cache curl ipset perl tzdata

# Set timezone
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone

COPY --from=builder /app/chinadns-ng /usr/local/bin/chinadns-ng
COPY entrypoint.sh /usr/local/bin/

RUN mkdir /etc/chinadns-ng
COPY chnroute.ipset /etc/chinadns-ng/
COPY chnroute6.ipset /etc/chinadns-ng/
COPY update-chnlist.sh /etc/chinadns-ng/
COPY update-chnroute.sh /etc/chinadns-ng/
COPY update-chnroute6.sh /etc/chinadns-ng/
COPY update-gfwlist.sh /etc/chinadns-ng/
COPY update-all.sh /etc/chinadns-ng/
COPY cron.sh /etc/chinadns-ng/

RUN echo "30 4 * * * cd /etc/chinadns-ng/ && ./cron.sh 2>&1 > /dev/null" >> /etc/crontabs/root

WORKDIR /etc/chinadns-ng/
ENTRYPOINT ["entrypoint.sh"]
