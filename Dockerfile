FROM node:22@sha256:1f097426a7ddd1c5d0eacfe0402fdf91e38e4ecc37d23780428f6b87145ad2aa AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:22@sha256:1f097426a7ddd1c5d0eacfe0402fdf91e38e4ecc37d23780428f6b87145ad2aa AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
