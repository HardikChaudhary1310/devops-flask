URL="${HEALTH_URL:-http://localhost:5000/health}"
INTERVAL="${INTERVAL:-10}"
while true; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL")
  echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') | $URL | HTTP $CODE"
  sleep "$INTERVAL"
done
