# Quickstart Setup Script for Jenkins CI/CD Controller (PowerShell)
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🚀 Launching Jenkins Automation Controller (Docker on Windows)" -ForegroundColor Green
Write-Host "=========================================================="

docker network create cicd-network 2>$null | Out-Null

Write-Host "🐳 Starting Jenkins container on port 8080..." -ForegroundColor Cyan
docker run -d `
    --name jenkins-ci-server `
    --restart unless-stopped `
    --network cicd-network `
    -u root `
    -p 8080:8080 `
    -p 50000:50000 `
    -v jenkins_home:/var/jenkins_home `
    -v //var/run/docker.sock:/var/run/docker.sock `
    jenkins/jenkins:lts-jdk17

Write-Host "⏳ Waiting 15s for Jenkins initialization..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "🔑 Jenkins Initial Admin Password:" -ForegroundColor Green
docker exec jenkins-ci-server cat /var/jenkins_home/secrets/initialAdminPassword

Write-Host "🌐 Jenkins Web UI: http://localhost:8080" -ForegroundColor Cyan
