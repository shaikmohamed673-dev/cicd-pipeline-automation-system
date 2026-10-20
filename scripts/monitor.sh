#!/usr/bin/env bash
# ====================================================================
# Container & Deployment Status Monitor Script
# Project: CI/CD Pipeline Automation System
# ====================================================================

set -e

CONTAINER_NAME="${1:-cicd-web-app}"
PORT="${2:-3000}"

echo "=========================================================="
echo "📊 CI/CD Deployment Observability & Status Monitor"
echo "=========================================================="

echo -e "\n1️⃣ Active Docker Containers:"
docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"

echo -e "\n2️⃣ Resource Consumption (CPU & Memory):"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}" "${CONTAINER_NAME}" 2>/dev/null || echo "Container not actively reporting stats."

echo -e "\n3️⃣ Docker Native Healthcheck Status:"
docker inspect --format='{{json .State.Health}}' "${CONTAINER_NAME}" 2>/dev/null || echo "No health status available."

echo -e "\n4️⃣ Live /health Endpoint Output:"
curl -s "http://localhost:${PORT}/health" | grep -o '"status":"[^"]*"' || echo "Unable to connect to http://localhost:${PORT}/health"

echo -e "\n5️⃣ Recent Application Logs (last 25 lines):"
docker logs --tail 25 "${CONTAINER_NAME}" 2>/dev/null || echo "No container logs available."

echo -e "\n=========================================================="
