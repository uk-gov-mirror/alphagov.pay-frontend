FROM node:12.20.1-alpine3.12@sha256:e63dd88799eeccf4f2869963bf79fb2aa7fa24aacf22ef9d6603c0c3ee7f4a07

### Needed to run appmetrics and pact-mock-service
COPY sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub
RUN ["apk", "--no-cache", "add", "ca-certificates", "python2", "build-base"]
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk && apk add --no-cache glibc-2.28-r0.apk && rm -f glibc-2.28-r0.apk
###

RUN ["apk", "--no-cache", "upgrade"]

RUN ["apk", "add", "--no-cache", "tini"]

ADD package.json /tmp/package.json
ADD package-lock.json /tmp/package-lock.json
RUN cd /tmp && npm install --production

ENV PORT 9000
EXPOSE 9000

WORKDIR /app
ADD . /app
ENV LD_LIBRARY_PATH /app/node_modules/appmetrics
RUN ["ln", "-s", "/tmp/node_modules", "/app/node_modules"]

ENTRYPOINT ["tini", "--"]

CMD ["npm", "start"]
