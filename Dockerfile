FROM node:22@sha256:4f7fb7f5f716f2175f5e7716f2a6cb310e82f3c72152b78d8c1ff58068988c0b AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:22@sha256:4f7fb7f5f716f2175f5e7716f2a6cb310e82f3c72152b78d8c1ff58068988c0b AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
