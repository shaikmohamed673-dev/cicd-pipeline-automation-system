# ====================================================================
# Automated Zero-Downtime Container Deployment Script (PowerShell)
# Project: CI/CD Pipeline Automation System
# Author: Shaik Mohamed
# ====================================================================

param(
    [string]$ContainerName = "cicd-web-app-prod",
    [string]$DockerImage = "shaikmohamed673/cicd-pipeline-app",
    [string]$ImageTag = "latest",
    [int]$AppPort = 3000
)

$FullImage = "$DockerImage`:$ImageTag"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🚀 Initiating Automated Container Deployment (PowerShell)" -ForegroundColor Green
Write-Host "📦 Target Image: $FullImage"
Write-Host "🏷️ Container Name: $ContainerName"
Write-Host "🌐 Port Mapping: ${AppPort}:3000"
Write-Host "=========================================================="

# Check for existing running container
$OldContainer = docker ps -q -f "name=^/${ContainerName}$"
if ($OldContainer) {
    Write-Host "🔍 Staging active container for rollback protection..." -ForegroundColor Yellow
    docker rename $ContainerName "${ContainerName}_previous"
}

# Run new container
Write-Host "🐳 Launching new container from $FullImage..." -ForegroundColor Cyan
docker run -d `
    --name $ContainerName `
    --restart unless-stopped `
    -p "${AppPort}:3000" `
    -e NODE_ENV=production `
    -e PORT=3000 `
    -e BUILD_NUMBER=$ImageTag `
    $FullImage

# Probe health
$HealthUrl = "http://localhost:${AppPort}/health"
$MaxAttempts = 12
$WaitSeconds = 3
$Success = $false

Write-Host "🩺 Verifying container health status..." -ForegroundColor Cyan
for ($i = 1; $i -le $MaxAttempts; $i++) {
    Write-Host "  [Attempt $i/$MaxAttempts] Probing $HealthUrl..."
    try {
        $response = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $Success = $true
            break
        }
    } catch {
        # continue loop
    }
    Start-Sleep -Seconds $WaitSeconds
}

if ($Success) {
    Write-Host "✅ Health check PASSED! HTTP 200 OK from $HealthUrl" -ForegroundColor Green
    
    # Remove previous container
    $Prev = docker ps -a -q -f "name=^/${ContainerName}_previous$"
    if ($Prev) {
        Write-Host "🧹 Cleaning up previous container version..." -ForegroundColor Gray
        docker stop "${ContainerName}_previous" | Out-Null
        docker rm "${ContainerName}_previous" | Out-Null
    }

    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "🎉 Deployment Succeeded! Live on http://localhost:$AppPort" -ForegroundColor Green
    Write-Host "=========================================================="
    exit 0
} else {
    Write-Host "❌ Health check FAILED! Gathering container logs:" -ForegroundColor Red
    docker logs --tail 40 $ContainerName

    Write-Host "⚠️ Rolling back to previous stable container..." -ForegroundColor Yellow
    docker stop $ContainerName | Out-Null
    docker rm $ContainerName | Out-Null

    $Prev = docker ps -a -q -f "name=^/${ContainerName}_previous$"
    if ($Prev) {
        docker rename "${ContainerName}_previous" $ContainerName
        docker start $ContainerName
        Write-Host "✅ Rollback succeeded. Previous version restored." -ForegroundColor Green
    }
    exit 1
}
