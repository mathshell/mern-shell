#!/bin/bash
set -e

echo "Starting rollback..."

kubectl rollout undo deployment/mern-app -n mern-app
kubectl rollout status deployment/mern-app -n mern-app

echo "Rollback completed successfully!"
