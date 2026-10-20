#!/usr/bin/env bash
# ====================================================================
# Health Check Verification Script
# Project: CI/CD Pipeline Automation System
# ====================================================================

set -e

TARGET_URL="${1:-http://localhost:3000/health}"
MAX_RETRIES="${2:-12}"
DELAY="${3:-2}"

echo "🩺 Initiating health probe against: ${TARGET_URL}"
echo "⏱️ Max Retries: ${MAX_RETRIES} (Delay: ${DELAY}s)"

for i in $(seq 1 "$MAX_RETRIES"); do
    echo "  [Probe #$i] Checking HTTP status..."
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL" || echo "000")

    if [ "$STATUS_CODE" -eq 200 ]; then
        echo "✅ SUCCESS: Target returned HTTP 200 OK!"
        echo "📄 Response Payload:"
        curl -s "$TARGET_URL"
        echo ""
        exit 0
    fi

    echo "  ⏳ Received HTTP $STATUS_CODE. Retrying in ${DELAY}s..."
    sleep "$DELAY"
done

echo "❌ FAILED: Health check probe did not succeed within timeout."
exit 1
