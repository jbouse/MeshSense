FROM node:23 AS builder

RUN apt update && \
    apt install -y \
      libdbus-1-dev \
      g++ \
      cmake

COPY . /app

WORKDIR /app
RUN git submodule update --init --recursive

WORKDIR /app/api/webbluetooth
RUN npm install && \
    npm run build:all

WORKDIR /app/api
RUN npm install && \
    npm run build

WORKDIR /app/ui
RUN npm install && \
    npm run build

FROM node:23-alpine 
EXPOSE 5920 5921

RUN apk --no-cache add dbus-dev

COPY --from=builder /app /app

WORKDIR /app/api/dist
CMD ["node", "index.cjs"]
