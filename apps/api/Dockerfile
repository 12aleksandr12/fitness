FROM node:22-alpine

WORKDIR /app

RUN apk add --no-cache openssl libc6-compat python3 make g++

COPY package.json package-lock.json* ./
RUN npm install || true

COPY . .

EXPOSE 3000

CMD ["npm", "run", "start:dev"]
