FROM node:21@sha256:64f5c0619b62db2dfdd13dfa1b8c3361dcc95ec4bcbbb82b63146e9efa5f1e7e AS build

WORKDIR /app

COPY package*.json .

RUN npm ci

COPY . .
RUN npm run build
RUN npm prune --production

FROM node:21@sha256:64f5c0619b62db2dfdd13dfa1b8c3361dcc95ec4bcbbb82b63146e9efa5f1e7e AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
