#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTAINER="${IRIS_CONTAINER:-iris-anvil-iris}"
BASE_URL="${IRIS_ANVIL_URL:-http://127.0.0.1:52773}"

for _ in $(seq 1 60); do
  code=$(curl -sS -o /dev/null -w '%{http_code}' "$BASE_URL/csp/sys/UtilHome.csp" 2>/dev/null || true)
  if [ "$code" != "" ] && [ "$code" != "000" ]; then break; fi
  sleep 1
done

docker exec -i "$CONTAINER" iris session IRIS < "$ROOT/scripts/bootstrap_iris.scr"

for _ in $(seq 1 60); do
  if curl -fsS "$BASE_URL/anvil/api/overview" >/dev/null 2>&1; then
    echo "IRIS Anvil bootstrap complete: $BASE_URL/anvil/index.html"
    exit 0
  fi
  sleep 1
done

echo "IRIS Anvil web application did not become ready" >&2
exit 1
