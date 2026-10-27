set -euo pipefail
SERVICE=web

[ -f .env ] || { echo ".env missing - run: cp .env.example .env"; exit 1; }

echo "==> Pulling latest image (falls back to local build)"
docker compose pull "$SERVICE" || docker compose build "$SERVICE"

echo "==> Recreating only the '$SERVICE' container"
docker compose up -d --no-deps --remove-orphans "$SERVICE"

echo "==> Waiting for healthy status"
for i in $(seq 1 30); do
  STATUS=$(docker inspect -f '{{.State.Health.Status}}' "$(docker compose ps -q $SERVICE)" 2>/dev/null || echo starting)
  [ "$STATUS" = "healthy" ] && { echo "Service healthy"; break; }
  sleep 2
done
[ "$STATUS" = "healthy" ] || { echo "Service failed health check"; docker compose logs --tail=50 "$SERVICE"; exit 1; }

docker compose up -d monitor
docker image prune -f >/dev/null
echo "==> Deploy complete: http://localhost:${HOST_PORT:-5000}"
