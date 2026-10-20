#!/usr/bin/env bash
# ====================================================================
# Quickstart Setup Script for Jenkins CI/CD Controller in Docker
# Project: CI/CD Pipeline Automation System
# ====================================================================

set -e

echo "=========================================================="
echo "🚀 Setting up Jenkins Automation Controller with Docker Socket"
echo "=========================================================="

# Create local docker network
docker network create cicd-network 2>/dev/null || true

# Run Jenkins with Docker-out-of-Docker socket mount
echo "🐳 Launching Jenkins container..."
docker run -d \
    --name jenkins-ci-server \
    --restart unless-stopped \
    --network cicd-network \
    -u root \
    -p 8080:8080 \
    -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins/jenkins:lts-jdk17

echo "⏳ Waiting for Jenkins to initialize initial admin password..."
sleep 15

echo "🔑 Jenkins Initial Admin Password:"
docker exec jenkins-ci-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Run: docker exec jenkins-ci-server cat /var/jenkins_home/secrets/initialAdminPassword"

echo "=========================================================="
echo "🌐 Jenkins is accessible at: http://localhost:8080"
echo "=========================================================="
