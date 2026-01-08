#!/bin/bash
# Script khởi động lại services sau khi restart máy

echo "=== Starting services ==="

# 1. Check Docker
echo "1. Checking Docker..."
if ! docker ps &> /dev/null; then
    echo "   Docker not running, starting..."
    sudo systemctl start docker
    sleep 3
fi
echo "   ✓ Docker is running"

# 2. Check Jenkins
echo "2. Checking Jenkins..."
if ! docker ps | grep -q 23127356; then
    echo "   Starting Jenkins container..."
    docker start 23127356
    sleep 5
fi
echo "   ✓ Jenkins is running on http://localhost:8080"

# 3. Check FastAPI app
echo "3. Checking FastAPI app..."
if docker ps | grep -q fastapi-app; then
    echo "   ✓ FastAPI app is running on http://localhost:8000"
else
    echo "   ⚠ FastAPI app not running (will be deployed by Jenkins)"
fi

# 4. Ngrok
echo "4. Ngrok..."
echo "   ⚠ Ngrok needs manual start:"
echo "   Run: ngrok http 8080"
echo "   Then update GitHub webhook with new URL"

echo ""
echo "=== Summary ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
