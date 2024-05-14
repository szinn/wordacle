FROM node:21@sha256:f3f975c2c041b0bccb9ee1d71c34d7d98f0e88c21cf5826b67352e36cb1095a6 AS build

WORKDIR /app

COPY package*.json .

RUN npm ci --force

COPY . .
RUN npm run build
RUN npm prune --production --force

FROM node:21@sha256:f3f975c2c041b0bccb9ee1d71c34d7d98f0e88c21cf5826b67352e36cb1095a6 AS run

ENV NODE_ENV=production

WORKDIR /app
COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules
RUN ulimit -c unlimited
ENTRYPOINT ["node", "build"]

LABEL org.opencontainers.image.source https://github.com/szinn/wordacle
LABEL org.opencontainers.image.description "A Wordle Oracle"
