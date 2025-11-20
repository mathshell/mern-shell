# Étape 1 : build du frontend
FROM node:18-alpine AS frontend-builder
WORKDIR /frontend

COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN npm run build

# Étape 2 : build backend + intégrer frontend
FROM node:18-alpine AS backend
WORKDIR /app

# Copier package.json du backend et installer dépendances
COPY package*.json ./
RUN npm ci --only=production

# Copier tout le code backend
COPY . .

# Copier le build du frontend dans /public
COPY --from=frontend-builder /frontend/build ./public

# Créer un utilisateur non-root
RUN addgroup -S nodejs && adduser -S mernuser
RUN chown -R mernuser:nodejs /app
USER mernuser

EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000

CMD ["npm", "start"]
