FROM node:21@sha256:ff9d96004d63e65fe480ed19a642106eafa2c8ea3952f079f45307c2cb5d6bf2 AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:21@sha256:ff9d96004d63e65fe480ed19a642106eafa2c8ea3952f079f45307c2cb5d6bf2 AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
