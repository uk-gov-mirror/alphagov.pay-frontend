FROM node:22.22.2-alpine3.22@sha256:7ca86b26185d5e50eb42b95833373df9f8551f3b40dcda8c6425bceadcc9136c AS builder

WORKDIR /app
COPY package.json .
COPY package-lock.json .
RUN npm ci --quiet

COPY . .
RUN npm run compile

FROM node:22.22.2-alpine3.22@sha256:7ca86b26185d5e50eb42b95833373df9f8551f3b40dcda8c6425bceadcc9136c AS final

RUN ["apk", "--no-cache", "upgrade"]

RUN ["apk", "add", "--no-cache", "tini"]

WORKDIR /app
COPY . .
RUN rm -rf ./test
# Copy in compile assets and deps from build container
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/govuk_modules ./govuk_modules
COPY --from=builder /app/public ./public
RUN npm prune --omit=dev

ENV PORT 9000
EXPOSE 9000

ENTRYPOINT ["tini", "--"]

CMD ["npm", "start"]
