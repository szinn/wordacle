FROM node:21@sha256:d3ee0a2a4db7a41c2e13a75caa40308546711122067f7ae48a9df7529c2d8070 AS build

WORKDIR /app

COPY package*.json .

RUN npm ci

COPY . .
RUN npm run build
RUN npm prune --production

FROM node:21@sha256:d3ee0a2a4db7a41c2e13a75caa40308546711122067f7ae48a9df7529c2d8070 AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
