FROM node:21@sha256:e49d3d153f2dc9b74ad8477471cdc64db85f3fe3de1620befe21786fe6e6a0cb AS build

WORKDIR /app

COPY package*.json .

RUN npm ci

COPY . .
RUN npm run build
RUN npm prune --production

FROM node:21@sha256:e49d3d153f2dc9b74ad8477471cdc64db85f3fe3de1620befe21786fe6e6a0cb AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
