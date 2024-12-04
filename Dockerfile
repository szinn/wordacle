FROM node:22@sha256:35a5dd72bcac4bce43266408b58a02be6ff0b6098ffa6f5435aeea980a8951d7 AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:22@sha256:35a5dd72bcac4bce43266408b58a02be6ff0b6098ffa6f5435aeea980a8951d7 AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
