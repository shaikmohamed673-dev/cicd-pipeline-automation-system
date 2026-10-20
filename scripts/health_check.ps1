# Health Check Verification Script (PowerShell)
param(
    [string]$TargetUrl = "http://localhost:3000/health",
    [int]$MaxRetries = 12,
    [int]$DelaySeconds = 2
)

Write-Host "🩺 Initiating health probe against: $TargetUrl" -ForegroundColor Cyan

for ($i = 1; $i -le $MaxRetries; $i++) {
    Write-Host "  [Probe #$i] Checking HTTP status..."
    try {
        $res = Invoke-WebRequest -Uri $TargetUrl -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        if ($res.StatusCode -eq 200) {
            Write-Host "✅ SUCCESS: Target returned HTTP 200 OK!" -ForegroundColor Green
            Write-Host $res.Content
            exit 0
        }
    } catch {
        Write-Host "  ⏳ Waiting for endpoint... ($($_.Exception.Message))" -ForegroundColor Gray
    }
    Start-Sleep -Seconds $DelaySeconds
}

Write-Host "❌ FAILED: Health probe did not succeed within timeout." -ForegroundColor Red
exit 1
