FROM node:21@sha256:162d92c5f1467ad877bf6d8a098d9b04d7303879017a2f3644bfb1de1fc88ff0 AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:21@sha256:162d92c5f1467ad877bf6d8a098d9b04d7303879017a2f3644bfb1de1fc88ff0 AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
