# Dockerització aplicació Sprint 2

# 1. Requisits Previs
Per garantir una instal·lació correcta, el sistema ha de complir amb:
* **Docker Engine**: v20.10 o superior.
* **Docker Compose**: v2.0 o superior.
* **Sistema operatiu**: Linux o WSL2 (en cas d'utilitzar Windows)


# 2. Estructura de Fitxers Rellevants

L'arquitectura del projecte es basa en els següents components:

* **`Dockerfile`**: Fitxer de definició multi-stage per a la creació de la imatge optimitzada.
* **`docker-compose.yml`**: Orquestració dels serveis (Aplicació, MariaDB i phpMyAdmin).
* **`.env`**: Configuració de les variables d'entorn i credencials de la base de dades.
* **`docker/apache.conf`**: Configuració personalitzada del servidor web Apache.
* **Volums (`db_data`)**: S'utilitzen volums per garantir la persistència de les dades de la base de dades MariaDB.

# 3. Instruccions per a Dockeritzar-la
Comanda per construir la imatge de l'aplicació localment:

```bash
docker build -t ecomotion-app:v1 .