@echo off
REM Démarre la plateforme DriveEasy sous Windows : une fenêtre par service.
REM Attendre que chaque fenêtre affiche "Started ..." avant d'utiliser l'application.
cd /d %~dp0

echo Compilation...
call mvn -q -DskipTests install || goto :erreur

echo Zipkin (Docker)...
docker compose up -d

start "service-registry" cmd /k "cd service-registry && mvn spring-boot:run"
timeout /t 25 /nobreak > nul
start "config-server" cmd /k "cd config-server && mvn spring-boot:run"
timeout /t 20 /nobreak > nul
start "vehicule-service" cmd /k "cd vehicule-service && mvn spring-boot:run"
start "client-service" cmd /k "cd client-service && mvn spring-boot:run"
start "location-service" cmd /k "cd location-service && mvn spring-boot:run"
timeout /t 30 /nobreak > nul
start "api-gateway" cmd /k "cd api-gateway && mvn spring-boot:run"

echo.
echo Eureka  : http://localhost:8761
echo Gateway : http://localhost:8080/api/vehicules
echo Zipkin  : http://localhost:9411
goto :eof

:erreur
echo La compilation a echoue.
