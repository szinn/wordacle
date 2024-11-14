FROM node:22@sha256:5c76d05034644fa8ecc9c2aa84e0a83cd981d0ef13af5455b87b9adf5b216561 AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:22@sha256:5c76d05034644fa8ecc9c2aa84e0a83cd981d0ef13af5455b87b9adf5b216561 AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
