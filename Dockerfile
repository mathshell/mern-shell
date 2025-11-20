# Dockerfile corrigé

# Étape 1 : build du frontend
# Changement : Passage à Node 16.x pour la compatibilité générale (MERN utilise souvent v14/v16)
FROM node:16-alpine AS frontend-builder
WORKDIR /frontend

# --- Optimisation du Cache ---
# Copie SEULEMENT des fichiers de configuration pour le cache
COPY frontend/package*.json ./
# Si les fichiers package.json ne changent pas, cette étape sera mise en cache.
RUN npm ci

# Copier le reste du code et builder
COPY frontend/ ./
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN npm run build

# ---
# Étape 2 : build backend + intégrer frontend
# Changement : Utilisation de Node 16-alpine pour être cohérent avec le frontend et éviter l'avertissement EBADENGINE (qui demandait 14.x)
FROM node:16-alpine AS backend 
WORKDIR /app

# Copier package.json du backend et installer dépendances
COPY package*.json ./
# Si les package.json changent, cette étape est relancée. Sinon, elle utilise le cache.
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
