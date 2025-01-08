FROM node:22@sha256:99981c3d1aac0d98cd9f03f74b92dddf30f30ffb0b34e6df8bd96283f62f12c6 AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:22@sha256:99981c3d1aac0d98cd9f03f74b92dddf30f30ffb0b34e6df8bd96283f62f12c6 AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
