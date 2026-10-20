#!/usr/bin/env bash
# ====================================================================
# Automated Zero-Downtime Container Deployment Script
# Project: CI/CD Pipeline Automation System
# Author: Shaik Mohamed
# ====================================================================

set -eo pipefail

APP_NAME="cicd-pipeline-app"
CONTAINER_NAME="${CONTAINER_NAME:-cicd-web-app-prod}"
DOCKER_IMAGE_NAME="${DOCKER_IMAGE_NAME:-shaikmohamed673/cicd-pipeline-app}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
APP_PORT="${APP_PORT:-3000}"
FULL_IMAGE="${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"

echo "=========================================================="
echo "🚀 Initiating Automated Container Deployment"
echo "📦 Target Image: ${FULL_IMAGE}"
echo "🏷️ Container Name: ${CONTAINER_NAME}"
echo "🌐 Port Mapping: ${APP_PORT}:3000"
echo "=========================================================="

# Step 1: Check for running existing container & capture backup ID
OLD_CONTAINER_ID=$(docker ps -q -f name="^/${CONTAINER_NAME}$" || true)

if [ -n "$OLD_CONTAINER_ID" ]; then
    echo "🔍 Found active container: ${OLD_CONTAINER_ID}"
    echo "🏷️ Staging existing container for zero-downtime cutover..."
    docker rename "${CONTAINER_NAME}" "${CONTAINER_NAME}_previous" || true
fi

# Step 2: Spin up the new container
echo "🐳 Launching new container from image: ${FULL_IMAGE}..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    --restart unless-stopped \
    -p "${APP_PORT}:3000" \
    -e NODE_ENV=production \
    -e PORT=3000 \
    -e BUILD_NUMBER="${IMAGE_TAG}" \
    "${FULL_IMAGE}"

# Step 3: Verify deployment via health check probe
echo "🩺 Verifying container health status..."
HEALTH_URL="http://localhost:${APP_PORT}/health"
MAX_ATTEMPTS=12
WAIT_SECONDS=3
DEPLOY_SUCCESS=false

for i in $(seq 1 $MAX_ATTEMPTS); do
    echo "  [Attempt $i/$MAX_ATTEMPTS] Probing ${HEALTH_URL}..."
    if curl -s -f -o /dev/null "$HEALTH_URL"; then
        DEPLOY_SUCCESS=true
        break
    fi
    sleep $WAIT_SECONDS
done

# Step 4: Handle health check outcome
if [ "$DEPLOY_SUCCESS" = true ]; then
    echo "✅ Health check PASSED! HTTP 200 OK received from ${HEALTH_URL}"
    
    # Clean up previous container
    if docker ps -a -q -f name="^/${CONTAINER_NAME}_previous$" | grep -q .; then
        echo "🧹 Stopping and removing previous container version..."
        docker stop "${CONTAINER_NAME}_previous" || true
        docker rm "${CONTAINER_NAME}_previous" || true
    fi

    # Cleanup dangling images
    docker image prune -f --filter "dangling=true" || true

    echo "=========================================================="
    echo "🎉 Deployment Completed Successfully!"
    echo "🌐 Live Endpoint: http://localhost:${APP_PORT}"
    echo "=========================================================="
    exit 0
else
    echo "❌ Health check FAILED! The new container failed to report healthy."
    echo "📋 Capturing container failure logs:"
    docker logs --tail 50 "${CONTAINER_NAME}" || true

    echo "⚠️ Initiating automated rollback..."
    docker stop "${CONTAINER_NAME}" || true
    docker rm "${CONTAINER_NAME}" || true

    if docker ps -a -q -f name="^/${CONTAINER_NAME}_previous$" | grep -q .; then
        echo "🔄 Restoring previous container..."
        docker rename "${CONTAINER_NAME}_previous" "${CONTAINER_NAME}" || true
        docker start "${CONTAINER_NAME}" || true
        echo "✅ Rollback complete. Previous version restored."
    else
        echo "⚠️ No previous container to restore."
    fi

    exit 1
fi
