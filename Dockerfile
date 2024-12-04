FROM node:22@sha256:ebf4cb185bca60e3d33a3a9d7df436280ebd38ae715ee6e7e82271f2dee04434 AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:22@sha256:ebf4cb185bca60e3d33a3a9d7df436280ebd38ae715ee6e7e82271f2dee04434 AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
