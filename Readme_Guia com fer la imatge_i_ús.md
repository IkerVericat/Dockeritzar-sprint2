# Dockerització de l'Aplicació EcoMotion - Sprint 2

## Introducció

Aquest document explica com hem dockeritzat l'aplicació EcoMotion seguint la documentació del [curs de Docker - Distribución de imágenes](https://github.com/josedom24/curso_docker_ow/blob/main/contenido/modulo7/distribucion.md).

Hem creat una **imatge mínima** que només conté els fitxers PHP de l'aplicació (sense dependencies).

---

## 1. Creació de la Imatge Docker Mínima

### 1.1 El Dockerfile

He creat un Dockerfile mínim que només copia els fitxers de l'aplicació:

```dockerfile
# Imatge mínima només amb els fitxers de l'aplicació
FROM scratch
COPY ./app /app
COPY ./public /public
COPY ./routes /routes
COPY ./config /config
COPY ./assets /assets
COPY ./css /css
```

### 1.2 Construcció de la Imatge

```powershell
docker build -t sergi/ecomotion-app:minimal .
```

### 1.3 Exportar la Imatge

Segons el [curs de distribució](https://github.com/josedom24/curso_docker_ow/blob/main/contenido/modulo7/distribucion.md), he exportat la imatge amb `docker save`:

```powershell
docker save sergi/ecomotion-app:minimal -o ecomotion-web.tar
```

**Mida final**: **1.17 MB** (només els fitxers PHP, sense Apache ni dependencies)

---

## 2. Instruccions per a la Professora

### 2.1 Requisits

- Docker Desktop instal·lat i funcionant

### 2.2 Fitxers Necessaris

Abans de començar, cal crear aquests fitxers al mateix directori on tens `ecomotion-web`:

#### Fitxer: `.env`

Crea un fitxer anomenat `.env` amb aquest contingut:

```bash
# MariaDB Configuration
MARIADB_ROOT_PASSWORD=root_password_123
MARIADB_DATABASE=ecomotiondb
MARIADB_USER=ecomotion_user
MARIADB_PASSWORD=ecomotion_pass_123
```

#### Fitxer: `docker-compose.yml`

Crea un fitxer anomenat `docker-compose.yml` amb aquest contingut:

```yaml
version: '3.9'

services:
  web:
    image: php:8.2-apache
    container_name: EcoMotion_Environment
    ports:
      - "8081:80"
    volumes:
      - app_files:/var/www/html
    environment:
      MARIADB_HOST: mariadb
      MARIADB_PORT: 3306
      MARIADB_DATABASE: ${MARIADB_DATABASE}
      MARIADB_DB: ${MARIADB_DATABASE}
      MARIADB_USER: ${MARIADB_USER}
      MARIADB_PASSWORD: ${MARIADB_PASSWORD}
    depends_on:
      - mariadb
    restart: always
    command: >
      bash -c "apt-get update && apt-get install -y libmariadb-dev && 
      docker-php-ext-install pdo pdo_mysql && 
      a2enmod rewrite && 
      sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf &&
      sed -i 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf &&
      apache2-foreground"

  mariadb:
    image: mariadb:11
    container_name: mariadb_db
    environment:
      MARIADB_ROOT_PASSWORD: ${MARIADB_ROOT_PASSWORD}
      MARIADB_DATABASE: ${MARIADB_DATABASE}
      MARIADB_USER: ${MARIADB_USER}
      MARIADB_PASSWORD: ${MARIADB_PASSWORD}
    ports:
      - "3306:3306"
    volumes:
      - mariadb_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: always

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    environment:
      PMA_HOST: mariadb
      PMA_USER: ${MARIADB_USER}
      PMA_PASSWORD: ${MARIADB_PASSWORD}
    ports:
      - "5053:80"
    depends_on:
      - mariadb
    restart: always

volumes:
  mariadb_data:
  app_files:
```

#### Fitxer: `init.sql`

Aquest fitxer està inclòs al GitHub dins de la carpeta `config/`. Col·loca'l al mateix directori que `docker-compose.yml`.

#### Fitxer: `seed.sql` (Opcional)

Aquest fitxer amb dades de prova està inclòs al GitHub dins de la carpeta `config/`. Pots usar-lo per carregar usuaris i vehicles de mostra.

### 2.3 Passos per Executar l'Aplicació

**1. Carregar la imatge amb els fitxers de l'aplicació:**

```powershell
docker load -i ecomotion-web.tar
```

Això carregarà la imatge `sergi/ecomotion-app:minimal` que conté els fitxers PHP.

**2. Extreure els fitxers de la imatge al volum:**

```powershell
# Crear un contenidor temporal per copiar els fitxers
docker create --name temp_extract sergi/ecomotion-app:minimal

# Copiar els fitxers al directori actual
docker cp temp_extract:/app ./app
docker cp temp_extract:/public ./public
docker cp temp_extract:/routes ./routes
docker cp temp_extract:/config ./config
docker cp temp_extract:/assets ./assets
docker cp temp_extract:/css ./css

# Eliminar el contenidor temporal
docker rm temp_extract
```

**3. Iniciar amb Docker Compose:**

```powershell
docker compose up -d
```

Docker Compose instal·larà automàticament:
- PHP 8.2 + Apache
- Extensions MySQL (pdo, pdo_mysql)
- MariaDB 11
- phpMyAdmin

**4. Carregar dades de prova (opcional):**

Si has creat el fitxer `seed.sql`:
- Accedeix a phpMyAdmin: http://localhost:5053
- Usuari: `ecomotion_user` / Password: `ecomotion_pass_123`
- Selecciona la base de dades `ecomotiondb`
- Importa o executa el fitxer `seed.sql`

**5. Accedir a l'aplicació:**

- Aplicació web: http://localhost:8081
- phpMyAdmin: http://localhost:5053

### 2.4 Credencials de Prova

| Rol | Email | Contrasenya |
|-----|-------|-------------|
| Super Admin | admin@ecomotion.com | admin123 |
| Manager | manager@acme.test | manager123 |
| Client | client1@acme.test | client123 |

---

## 3. Arquitectura del Sistema

El projecte utilitza Docker Compose amb 3 contenidors:

- **Web**: PHP 8.2 + Apache (port 8081)
- **MariaDB**: Base de dades (port 3306)
- **phpMyAdmin**: Administració de BD (port 5053)

---

## 4. Comandes Útils

```powershell
# Veure l'estat
docker compose ps

# Veure logs
docker compose logs

# Aturar
docker compose stop

# Reiniciar
docker compose restart
```

---

## Referències

- [Curso Docker - Construcción de imágenes](https://github.com/josedom24/curso_docker_ow/blob/main/contenido/modulo7/build.md)
- [Curso Docker - Distribución de imágenes](https://github.com/josedom24/curso_docker_ow/blob/main/contenido/modulo7/distribucion.md)
