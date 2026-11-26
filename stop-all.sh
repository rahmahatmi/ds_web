#!/usr/bin/env bash
# Arrête les services lancés par start-all.sh
cd "$(dirname "$0")"
for f in logs/*.pid; do
  [ -f "$f" ] || continue
  pid=$(cat "$f")
  # mvn spring-boot:run lance un processus Java enfant : on arrête l'arbre complet
  pkill -P "$pid" 2>/dev/null; kill "$pid" 2>/dev/null
  rm -f "$f"
done
echo "Services arrêtés. (Zipkin : docker compose down)"
