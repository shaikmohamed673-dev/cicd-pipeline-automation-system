#!/usr/bin/env bash
# ====================================================================
# Container Automated Rollback Script
# Project: CI/CD Pipeline Automation System
# Author: Shaik Mohamed
# ====================================================================

set -eo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-cicd-web-app-prod}"

echo "=========================================================="
echo "⚠️ EMERGENCY ROLLBACK TRIGGERED for ${CONTAINER_NAME}"
echo "=========================================================="

if docker ps -a -q -f name="^/${CONTAINER_NAME}_previous$" | grep -q .; then
    echo "🔍 Found backed up container: ${CONTAINER_NAME}_previous"
    
    echo "🛑 Halting broken container..."
    docker stop "${CONTAINER_NAME}" || true
    docker rm "${CONTAINER_NAME}" || true

    echo "🔄 Promoting previous container to active service..."
    docker rename "${CONTAINER_NAME}_previous" "${CONTAINER_NAME}"
    docker start "${CONTAINER_NAME}"

    echo "✅ Rollback executed successfully. Traffic restored."
    exit 0
else
    echo "❌ No previous container backup found to restore."
    exit 1
fi
