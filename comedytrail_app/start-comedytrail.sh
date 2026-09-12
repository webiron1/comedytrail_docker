#!/bin/bash
set -e

echo "========================================"
echo "ComedyTrail Container Startup"
echo "========================================"

# Wait for MySQL database
echo ""
echo "Waiting for MySQL database..."
MAX_ATTEMPTS=3
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    if mysql --host=comedytrail_db --user=comedytrail_user --password=comedytrail_secret -e "SELECT 1" &>/dev/null; then
        echo "[OK] Database comedytrail_db is ready!"
        break
    fi
    echo "  [Attempt $ATTEMPT/$MAX_ATTEMPTS] Retrying in 1 second..."
    sleep 1
    ATTEMPT=$((ATTEMPT + 1))
done

if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
    echo "[WARNING] Database connection failed after $MAX_ATTEMPTS attempts"
    echo "Continuing startup anyway..."
fi

echo ""
echo "========================================"
echo "Starting systemd (PID 1)..."
echo "========================================"
echo ""

exec /lib/systemd/systemd
