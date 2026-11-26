#!/usr/bin/env bash
# Démarre toute la plateforme DriveEasy dans l'ordre recommandé (Linux / macOS / Git Bash).
# Les logs de chaque service sont écrits dans ./logs/<service>.log
# Arrêt : ./stop-all.sh
set -e
cd "$(dirname "$0")"
mkdir -p logs

echo "==> Compilation de tous les modules"
mvn -q -DskipTests install

attendre() {  # attendre <nom> <url>
  echo -n "    attente de $1"
  for _ in $(seq 1 90); do
    if curl -sf "$2" > /dev/null 2>&1; then echo " : OK"; return 0; fi
    echo -n "."; sleep 2
  done
  echo " : ECHEC (voir logs/$1.log)"; exit 1
}

lancer() {  # lancer <module>
  echo "==> Démarrage de $1"
  (cd "$1" && nohup mvn -q spring-boot:run > "../logs/$1.log" 2>&1 & echo $! > "../logs/$1.pid")
}

echo "==> Zipkin (Docker)"
docker compose up -d || echo "    Docker indisponible : Zipkin non démarré (les services fonctionnent quand même)"

lancer service-registry;  attendre service-registry  http://localhost:8761/actuator/health
lancer config-server;     attendre config-server     http://localhost:8888/actuator/health
lancer vehicule-service;  attendre vehicule-service  http://localhost:8081/actuator/health
lancer client-service;    attendre client-service    http://localhost:8082/actuator/health
lancer location-service;  attendre location-service  http://localhost:8083/actuator/health
lancer api-gateway;       attendre api-gateway       http://localhost:8080/actuator/health

echo
echo "Plateforme démarrée :"
echo "  Eureka  : http://localhost:8761"
echo "  Gateway : http://localhost:8080/api/vehicules"
echo "  Zipkin  : http://localhost:9411"
