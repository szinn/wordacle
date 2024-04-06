FROM node:21@sha256:fa5e7e628c8fe0ebfd13239b0103de36df36903fc7fee18da9755d022b2b910f AS build

WORKDIR /app

COPY package*.json .

RUN npm ci

COPY . .
RUN npm run build
RUN npm prune --production

FROM node:21@sha256:fa5e7e628c8fe0ebfd13239b0103de36df36903fc7fee18da9755d022b2b910f AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
