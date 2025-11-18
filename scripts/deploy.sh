#!/bin/bash
set -e

echo "Starting deployment..."

# Build et push de l'image
docker build -t localhost:8000/mern-app:$GIT_COMMIT -f docker/Dockerfile .
docker push localhost:8000/mern-app:$GIT_COMMIT

# Mise à jour de l'image dans le deployment
kubectl set image deployment/mern-app mern-app=localhost:8000/mern-app:$GIT_COMMIT -n mern-app

# Attendre que le déploiement soit terminé
kubectl rollout status deployment/mern-app -n mern-app

echo "Deployment completed successfully!"
