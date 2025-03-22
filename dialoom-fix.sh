#!/bin/bash

# dialoom-fix.sh - Script de reparación completa para Dialoom
# Este script debe ejecutarse como fremmenn2 o con su

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Configuración
DOMAIN="web.dialoom.com"
BASE_DIR="/var/www/vhosts/${DOMAIN}/httpdocs"
WEB_USER="${DOMAIN}_fremmenn2"
WEB_GROUP="psacln"

# Verificar ejecución como usuario correcto
if [[ "$(whoami)" != "fremmenn2" && "$(whoami)" != "root" ]]; then
  log_error "Este script debe ejecutarse como fremmenn2 o root."
  exit 1
fi

# Verificar directorio base
if [ ! -d "$BASE_DIR" ]; then
  log_error "El directorio base $BASE_DIR no existe."
  exit 1
fi

# 1. Limpiar y preparar el entorno
log_step "Limpiando el entorno..."
cd "$BASE_DIR"

# Crear directorio de backup
BACKUP_TIME=$(date +%Y%m%d%H%M%S)
BACKUP_DIR="${BASE_DIR}/dialoom-backup-${BACKUP_TIME}"
mkdir -p "$BACKUP_DIR"

# Respaldar archivos existentes
if [ -d "${BASE_DIR}/dialoom-frontend" ]; then
  log_info "Respaldando directorio frontend existente..."
  cp -r "${BASE_DIR}/dialoom-frontend" "${BACKUP_DIR}/"
fi

# Si existe app.js, moverlo a backup
if [ -f "${BASE_DIR}/app.js" ]; then
  log_info "Respaldando app.js existente..."
  cp "${BASE_DIR}/app.js" "${BACKUP_DIR}/"
fi

# 2. Crear aplicación Node.js básica
log_step "Configurando aplicación Node.js básica..."

# Crear package.json en el directorio principal
cat > "${BASE_DIR}/package.json" << 'EOF'
{
  "name": "dialoom-server",
  "version": "1.0.0",
  "description": "Dialoom Server Application",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "compression": "^1.7.4",
    "cors": "^2.8.5",
    "http-errors": "^2.0.0"
  }
}
EOF

# Crear app.js - Servidor Express básico
cat > "${BASE_DIR}/app.js" << 'EOF'
const express = require('express');
const path = require('path');
const compression = require('compression');
const cors = require('cors');
const createError = require('http-errors');

// Crear aplicación Express
const app = express();
const port = process.env.PORT || 5001;

// Middleware
app.use(compression());
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Ruta API para verificar estado
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'Dialoom API'
  });
});

// Servir index.html para cualquier otra ruta (SPA handling)
app.get('*', (req, res) => {
  // Verificar si la ruta es un archivo API o recursos estáticos
  if (req.path.startsWith('/api/') || 
      req.path.includes('.')) {
    return next(createError(404));
  }
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Manejador de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: err.message || 'Error interno del servidor'
  });
});

// Iniciar servidor
app.listen(port, '127.0.0.1', () => {
  console.log(`Dialoom server running on port ${port}`);
});
EOF

# 3. Crear un frontend mínimo que funcione
log_step "Creando frontend mínimo funcional..."

# Crear directorio para el frontend estático
mkdir -p "${BASE_DIR}/public"

# Crear index.html básico
cat > "${BASE_DIR}/public/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dialoom - Plataforma de Mentores</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      margin: 0;
      padding: 0;
      background-color: #f5f5f5;
      color: #333;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    header {
      background-color: #1a7a8b;
      color: white;
      padding: 1rem;
      text-align: center;
    }
    .logo {
      font-size: 1.8rem;
      font-weight: bold;
      margin: 0;
    }
    main {
      flex: 1;
      padding: 2rem;
      max-width: 1200px;
      margin: 0 auto;
      width: 100%;
      box-sizing: border-box;
    }
    .card {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      padding: 2rem;
      margin-bottom: 2rem;
    }
    h1 {
      color: #1a7a8b;
      margin-top: 0;
    }
    footer {
      background-color: #333;
      color: white;
      text-align: center;
      padding: 1rem;
      margin-top: auto;
    }
    .button {
      display: inline-block;
      background-color: #1a7a8b;
      color: white;
      padding: 0.5rem 1rem;
      border-radius: 4px;
      text-decoration: none;
      margin-top: 1rem;
    }
    .button:hover {
      background-color: #136a7a;
    }
  </style>
</head>
<body>
  <header>
    <h1 class="logo">Dialoom</h1>
  </header>
  <main>
    <div class="card">
      <h1>Bienvenido a Dialoom</h1>
      <p>Plataforma de conexión entre mentores y aprendices.</p>
      <p>Esta es una página de muestra. El sitio está en construcción.</p>
      <a href="/api/health" class="button">Verificar API</a>
    </div>
    
    <div class="card">
      <h2>Estado del Servidor</h2>
      <p>El servidor web está funcionando correctamente.</p>
      <p>La aplicación está lista para ser desarrollada.</p>
    </div>
  </main>
  <footer>
    &copy; 2025 Dialoom - Todos los derechos reservados
  </footer>
</body>
</html>
EOF

# 4. Instalar dependencias
log_step "Instalando dependencias de Node.js..."
cd "$BASE_DIR"
if ! npm install; then
  log_warn "Problema instalando dependencies. Intentando con --legacy-peer-deps..."
  npm install --legacy-peer-deps
fi

# 5. Crear página de diagnóstico
log_step "Creando página de diagnóstico..."

mkdir -p "${BASE_DIR}/fallback"
cat > "${BASE_DIR}/fallback/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dialoom - Diagnóstico</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: #f8f8f8;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        h1 {
            color: #1a7a8b;
            border-bottom: 2px solid #1a7a8b;
            padding-bottom: 10px;
        }
        h2 {
            color: #0d5c6a;
            margin-top: 30px;
        }
        .status {
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .warning {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .code {
            font-family: monospace;
            background: #f1f1f1;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
        .links {
            margin-top: 30px;
        }
        .links a {
            margin-right: 15px;
            color: #1a7a8b;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Dialoom - Página de Diagnóstico</h1>
        
        <div class="status success">
            <strong>¡Página de diagnóstico accesible!</strong> El servidor Nginx está respondiendo correctamente.
        </div>
        
        <h2>Verificación de componentes</h2>
        
        <div id="apiStatus" class="status warning">
            Verificando estado de la API...
        </div>
        
        <div id="rootStatus" class="status warning">
            Verificando acceso a la raíz del sitio...
        </div>
        
        <h2>Información del servidor</h2>
        <div class="code">
            <p><strong>Fecha y hora del servidor:</strong> <span id="serverTime"></span></p>
            <p><strong>Ruta actual:</strong> <span id="currentPath"></span></p>
            <p><strong>Dominio:</strong> <span id="currentDomain"></span></p>
        </div>
        
        <h2>Acciones</h2>
        <div class="links">
            <a href="/" target="_blank">Ir al inicio</a>
            <a href="/api/health" target="_blank">Verificar API</a>
        </div>
    </div>

    <script>
        // Actualizar información del servidor
        document.getElementById('serverTime').textContent = new Date().toString();
        document.getElementById('currentPath').textContent = window.location.pathname;
        document.getElementById('currentDomain').textContent = window.location.hostname;
        
        // Verificar estado de la API
        fetch('/api/health')
            .then(response => {
                if (!response.ok) throw new Error('La API no responde correctamente');
                return response.json();
            })
            .then(data => {
                document.getElementById('apiStatus').className = 'status success';
                document.getElementById('apiStatus').innerHTML = `
                    <strong>✅ API funcionando correctamente</strong><br>
                    Respuesta: ${JSON.stringify(data)}
                `;
            })
            .catch(error => {
                document.getElementById('apiStatus').className = 'status error';
                document.getElementById('apiStatus').innerHTML = `
                    <strong>❌ Error conectando con la API</strong><br>
                    ${error.message}
                `;
            });
        
        // Verificar acceso a la raíz
        fetch('/')
            .then(response => {
                if (!response.ok) throw new Error('No se puede acceder a la raíz del sitio');
                return response.text();
            })
            .then(() => {
                document.getElementById('rootStatus').className = 'status success';
                document.getElementById('rootStatus').innerHTML = `
                    <strong>✅ Raíz del sitio accesible</strong><br>
                    La página principal responde correctamente.
                `;
            })
            .catch(error => {
                document.getElementById('rootStatus').className = 'status error';
                document.getElementById('rootStatus').innerHTML = `
                    <strong>❌ Error accediendo a la raíz</strong><br>
                    ${error.message}
                `;
            });
    </script>
</body>
</html>
EOF

# 6. Crear configuración de proxy para Nginx
log_step "Configurando Nginx..."

# Crear archivo de parámetros proxy
mkdir -p "${BASE_DIR}/conf"
cat > "${BASE_DIR}/conf/proxy_params" << 'EOF'
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Host $host;
proxy_set_header X-Forwarded-Port $server_port;
proxy_buffering off;
proxy_cache off;
EOF

# Crear configuración Nginx para Plesk
cat > "${BASE_DIR}/conf/nginx.conf" << 'EOF'
# Configuración Nginx para Dialoom
# Incluir en la sección del servidor virtual

# Proxy para Node.js
location / {
    proxy_pass http://127.0.0.1:5001;
    include proxy_params;
}

# API endpoints
location /api/ {
    proxy_pass http://127.0.0.1:5001;
    include proxy_params;
}

# Página de diagnóstico
location /fallback {
    alias /var/www/vhosts/web.dialoom.com/httpdocs/fallback;
    index index.html;
    try_files $uri $uri/ /fallback/index.html;
}

# Recursos estáticos
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    root /var/www/vhosts/web.dialoom.com/httpdocs/public;
    expires max;
    access_log off;
    try_files $uri =404;
}
EOF

# 7. Crear script de instalación de la configuración de Nginx
cat > "${BASE_DIR}/install_nginx_config.sh" << 'EOF'
#!/bin/bash

# Colores para mensajes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}[INFO]${NC} Instalando configuración de Nginx para Dialoom..."

# Obtener el ID del sitio web en Plesk
DOMAIN="web.dialoom.com"
SITE_ID=$(plesk bin site --info $DOMAIN -field id 2>/dev/null)

if [ -z "$SITE_ID" ]; then
    echo -e "${RED}[ERROR]${NC} No se pudo obtener el ID del sitio para $DOMAIN"
    exit 1
fi

# Copiar la configuración personalizada
echo -e "${BLUE}[INFO]${NC} Copiando configuración personalizada..."
mkdir -p "/var/www/vhosts/$DOMAIN/conf/web"
cp "/var/www/vhosts/$DOMAIN/httpdocs/conf/nginx.conf" "/var/www/vhosts/$DOMAIN/conf/web/nginx.conf"
cp "/var/www/vhosts/$DOMAIN/httpdocs/conf/proxy_params" "/var/www/vhosts/$DOMAIN/conf/proxy_params"

# Aplicar la configuración en Plesk
echo -e "${BLUE}[INFO]${NC} Recargando configuración de Nginx..."
plesk bin server_settings --update-web-server-config

echo -e "${GREEN}[OK]${NC} Configuración de Nginx actualizada correctamente."

# Verificar la configuración
plesk bin server_settings --show-nginx-restart

echo -e "${BLUE}[INFO]${NC} Para completar la instalación:"
echo "1. Reinicia Nginx desde el panel de Plesk"
echo "2. Verifica que Node.js esté configurado en Plesk con la ruta /var/www/vhosts/$DOMAIN/httpdocs y app.js como punto de entrada"
EOF

# 8. Crear script de inicio para PM2
cat > "${BASE_DIR}/pm2_start.sh" << 'EOF'
#!/bin/bash

# Colores para mensajes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

DOMAIN="web.dialoom.com"
APP_DIR="/var/www/vhosts/$DOMAIN/httpdocs"

echo -e "${BLUE}[INFO]${NC} Iniciando aplicación Dialoom con PM2..."

# Verificar si PM2 está instalado
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}[WARN]${NC} PM2 no está instalado. Instalando..."
    npm install -g pm2
fi

# Detener instancia anterior si existe
pm2 stop dialoom 2>/dev/null
pm2 delete dialoom 2>/dev/null

# Iniciar aplicación
cd "$APP_DIR"
pm2 start app.js --name dialoom

echo -e "${GREEN}[OK]${NC} Aplicación Dialoom iniciada con PM2."
pm2 list
EOF

# 9. Establecer permisos correctos
log_step "Configurando permisos..."

chown -R ${WEB_USER}:${WEB_GROUP} "${BASE_DIR}"
find "${BASE_DIR}" -type d -exec chmod 755 {} \;
find "${BASE_DIR}" -type f -name "*.sh" -exec chmod 755 {} \;
find "${BASE_DIR}" -type f -name "*.js" -exec chmod 644 {} \;
find "${BASE_DIR}" -type f -name "*.html" -exec chmod 644 {} \;
find "${BASE_DIR}" -type f -name "*.json" -exec chmod 644 {} \;

# Asegurar que los scripts son ejecutables
chmod +x "${BASE_DIR}/install_nginx_config.sh"
chmod +x "${BASE_DIR}/pm2_start.sh"

# 10. Crear archivo explicativo README
cat > "${BASE_DIR}/README.md" << 'EOF'
# Dialoom Server Installation

## Estructura

- `/app.js` - Servidor Express principal
- `/public/` - Archivos estáticos de frontend
- `/fallback/` - Página de diagnóstico
- `/conf/` - Archivos de configuración
- `/install_nginx_config.sh` - Script para instalar configuración Nginx
- `/pm2_start.sh` - Script para iniciar la aplicación con PM2

## Configuración en Plesk

1. Habilitar Node.js desde el panel de Plesk
2. Configurar el directorio raíz como `/var/www/vhosts/web.dialoom.com/httpdocs`
3. Establecer `app.js` como archivo de inicio
4. Ejecutar `install_nginx_config.sh` para configurar Nginx
5. Ejecutar `pm2_start.sh` para iniciar la aplicación con PM2 (opcional)

## Verificación

Accede a https://web.dialoom.com para ver la página principal
Accede a https://web.dialoom.com/fallback para ver la página de diagnóstico
Accede a https://web.dialoom.com/api/health para verificar la API
EOF

# 11. Instrucciones finales
log_step "Instalación completada con éxito!"
log_info "Pasos siguientes:"
log_info "1. Ejecutar el script de configuración de Nginx (como root):"
log_info "   sudo ${BASE_DIR}/install_nginx_config.sh"
log_info "2. Configurar Node.js en Plesk:"
log_info "   - Directorio raíz: ${BASE_DIR}"
log_info "   - Archivo de inicio: app.js"
log_info "3. Reiniciar aplicación Node.js desde el panel de Plesk"
log_info "4. Verificar acceso a https://${DOMAIN}"
log_info "5. En caso de problemas, verificar https://${DOMAIN}/fallback"
