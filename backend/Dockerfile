FROM node:24-bookworm-slim

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund

RUN install -d -o node -g node /app/data
COPY --chown=node:node src ./src

EXPOSE 4000
USER node

CMD ["npm", "start"]
