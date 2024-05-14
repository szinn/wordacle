FROM node:21@sha256:7b69aa65cfeabf33b1d76616d5b368d9d7b75a7f88ba011be92a4012476fd0cf AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:21@sha256:7b69aa65cfeabf33b1d76616d5b368d9d7b75a7f88ba011be92a4012476fd0cf AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
