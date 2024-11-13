FROM node:22@sha256:db556c2974040f7812c7f39c15afb1e8b1901d6e23f1975ff71b5236a1244e52 AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:22@sha256:db556c2974040f7812c7f39c15afb1e8b1901d6e23f1975ff71b5236a1244e52 AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
