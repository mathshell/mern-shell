#!/bin/bash
echo "=== Kubernetes Pods ==="
kubectl get pods -n mern-app

echo "=== Kubernetes Services ==="
kubectl get services -n mern-app

echo "=== Kubernetes Ingress ==="
kubectl get ingress -n mern-app

echo "=== Application Logs ==="
kubectl logs -l app=mern-app -n mern-app --tail=10
