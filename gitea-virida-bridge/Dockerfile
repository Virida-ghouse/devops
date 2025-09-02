FROM node:18-alpine

LABEL maintainer="VIRIDA Team <dev@virida.com>"
LABEL service="gitea-virida-bridge"
LABEL version="1.0.0"

ENV NODE_ENV=production
ENV PORT=3001

RUN apk add --no-cache curl
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev && npm cache clean --force

COPY . .
RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3001/health || exit 1

CMD ["npm", "start"]
