#!/bin/bash
# Script para arreglar la integración de Nginx con Node.js para Dialoom

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="web.dialoom.com"
APP_DIR="/var/www/vhosts/$DOMAIN/httpdocs"
FRONTEND_DIR="$APP_DIR/dialoom-frontend"

echo -e "${BLUE}[INFO]${NC} Iniciando corrección de integración Nginx-Node.js para Dialoom..."

# 1. Crear un archivo app.js optimizado para funcionar con Nginx y SSL
echo -e "${BLUE}[INFO]${NC} Creando app.js optimizado para Nginx/SSL..."

cat > "$APP_DIR/app.js" << 'EOF'
const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Logging detallado para diagnóstico
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.url}`);
  console.log(`[${timestamp}] Headers: ${JSON.stringify({
    host: req.headers.host,
    referer: req.headers.referer,
    'x-forwarded-proto': req.headers['x-forwarded-proto'],
    'x-forwarded-host': req.headers['x-forwarded-host'],
    'x-forwarded-for': req.headers['x-forwarded-for']
  })}`);
  next();
});

// Configuración para confiar en el proxy
app.set('trust proxy', true);

// Servir archivos estáticos desde el directorio dist
const distPath = path.join(__dirname, 'dialoom-frontend/dist');
console.log(`Directorio de la aplicación: ${distPath}`);

if (fs.existsSync(distPath)) {
  // Verificar si existe index.html
  const indexPath = path.join(distPath, 'index.html');
  if (fs.existsSync(indexPath)) {
    console.log(`index.html encontrado: ${indexPath} (${fs.statSync(indexPath).size} bytes)`);
  } else {
    console.error(`¡ALERTA! index.html NO encontrado en ${distPath}`);
  }

  // Servir archivos estáticos
  app.use(express.static(distPath, {
    etag: true,
    lastModified: true,
    setHeaders: (res, filePath) => {
      if (filePath.endsWith('.html')) {
        // No cachear HTML
        res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
      } else if (filePath.match(/\.(js|css|png|jpg|jpeg|gif|ico)$/)) {
        // Cachear recursos estáticos por 1 día
        res.setHeader('Cache-Control', 'public, max-age=86400');
      }
    }
  }));

  // Ruta para SPA - enviar siempre index.html
  app.get('*', (req, res) => {
    console.log(`Sirviendo index.html para: ${req.url}`);
    res.sendFile(path.join(distPath, 'index.html'));
  });
} else {
  console.error(`ERROR: El directorio dist no existe en: ${distPath}`);
  app.get('*', (req, res) => {
    res.status(500).send(`
      <html>
        <head>
          <title>Dialoom - Error</title>
          <style>
            body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
            h1 { color: #E53E3E; }
            .box { border: 1px solid #CBD5E0; border-radius: 8px; padding: 20px; margin: 20px 0; }
            code { background: #EDF2F7; padding: 2px 4px; border-radius: 4px; font-size: 90%; }
          </style>
        </head>
        <body>
          <h1>Error: Directorio de aplicación no encontrado</h1>
          <div class="box">
            <p>No se encontró el directorio de la aplicación en:</p>
            <code>${distPath}</code>
            <p>Por favor verifica que la aplicación ha sido compilada correctamente.</p>
          </div>
        </body>
      </html>
    `);
  });
}

// Iniciar el servidor
app.listen(PORT, () => {
  console.log(`Servidor Dialoom iniciado en puerto ${PORT}`);
  console.log(`Hora de inicio: ${new Date().toISOString()}`);
  console.log(`Node.js: ${process.version}`);
});
EOF

echo -e "${GREEN}[OK]${NC} app.js optimizado creado."

# 2. Verificar dependencias en el directorio raíz
echo -e "${BLUE}[INFO]${NC} Verificando dependencias en directorio raíz..."
cd "$APP_DIR"

# Instalar express si es necesario
if [ ! -d "node_modules/express" ]; then
  echo -e "${YELLOW}[AVISO]${NC} Instalando express..."
  npm install express --save
else
  echo -e "${GREEN}[OK]${NC} Express ya está instalado."
fi

# 3. Crear archivo proxy_params para Nginx
echo -e "${BLUE}[INFO]${NC} Creando archivo proxy_params para Nginx..."

# Crear archivo temporal
PROXY_PARAMS="/tmp/proxy_params.$$"
cat > "$PROXY_PARAMS" << 'EOF'
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Host $host;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_buffering off;
proxy_read_timeout 90s;
EOF

# 4. Crear configuración de Nginx optimizada
echo -e "${BLUE}[INFO]${NC} Creando configuración Nginx optimizada..."

# Crear archivo temporal
NGINX_CONF="/tmp/nginx.conf.$$"
cat > "$NGINX_CONF" << EOF
# Configuración Nginx para Dialoom con Node.js
server {
    listen 80;
    server_name $DOMAIN;
    
    # Redireccionar HTTP a HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    # Configuración SSL gestionada por Plesk
    
    # Directorio raíz para archivos estáticos fallback
    root $APP_DIR;
    
    # Gzip
    gzip on;
    gzip_comp_level 5;
    gzip_min_length 256;
    gzip_proxied any;
    gzip_vary on;
    gzip_types
        application/javascript
        application/json
        application/x-javascript
        text/css
        text/javascript
        text/plain;
    
    # Proxy a la aplicación Node.js
    location / {
        proxy_pass http://127.0.0.1:3000;
        include $PROXY_PARAMS;
    }
    
    # Fallback a archivos estáticos si Node.js no responde
    location /fallback {
        alias $APP_DIR/fallback;
        try_files \$uri /fallback/index.html;
    }
    
    # Cabeceras de seguridad
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
EOF

echo -e "${GREEN}[OK]${NC} Configuración Nginx creada."

# 5. Crear página de fallback
echo -e "${BLUE}[INFO]${NC} Creando página de fallback..."
mkdir -p "$APP_DIR/fallback"

cat > "$APP_DIR/fallback/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dialoom - Servicio Interrumpido</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 40px auto;
            padding: 0 20px;
            background-color: #f8f9fa;
        }
        h1 {
            color: #1A7A8B;
            border-bottom: 2px solid #1A7A8B;
            padding-bottom: 10px;
        }
        .card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .error {
            color: #E53E3E;
            border-left: 4px solid #E53E3E;
            padding-left: 15px;
            margin: 20px 0;
            background-color: rgba(229, 62, 62, 0.05);
            padding: 15px;
            border-radius: 4px;
        }
        code {
            background: #eee;
            padding: 2px 4px;
            border-radius: 4px;
            font-family: Monaco, monospace;
            font-size: 0.9em;
        }
        .button {
            display: inline-block;
            background-color: #1A7A8B;
            color: white;
            padding: 10px 20px;
            border-radius: 4px;
            text-decoration: none;
            margin-top: 20px;
        }
        .button:hover {
            background-color: #156978;
        }
    </style>
</head>
<body>
    <h1>Dialoom</h1>
    
    <div class="card">
        <h2>Servicio Temporalmente Interrumpido</h2>
        <p>La aplicación Dialoom está experimentando dificultades técnicas. Estamos trabajando para resolver el problema lo antes posible.</p>
        
        <div class="error">
            <p><strong>Diagnóstico:</strong> La aplicación Node.js no está respondiendo correctamente.</p>
        </div>
        
        <h3>Posibles soluciones:</h3>
        <ul>
            <li>Reiniciar la aplicación Node.js desde el panel de Plesk</li>
            <li>Verificar que la aplicación ha sido compilada correctamente</li>
            <li>Comprobar los logs de Node.js para más información</li>
        </ul>
        
        <a href="https://web.dialoom.com" class="button">Intentar acceder nuevamente</a>
    </div>
</body>
</html>
EOF

echo -e "${GREEN}[OK]${NC} Página de fallback creada."

# 6. Crear script para instalar/reiniciar servicios
echo -e "${BLUE}[INFO]${NC} Creando script de instalación y reinicio de servicios..."

cat > "$APP_DIR/install_config.sh" << EOF
#!/bin/bash
# Instalar configuración de proxy Nginx y reiniciar servicios

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "\${BLUE}[INFO]\${NC} Instalando configuración para Dialoom..."

# Copiar archivos de configuración
echo -e "\${BLUE}[INFO]\${NC} Copiando configuración de Nginx..."
cp "$PROXY_PARAMS" /var/www/vhosts/$DOMAIN/conf/proxy_params

# Verificar si debemos usar la nueva configuración de Nginx
if [ -d "/var/www/vhosts/$DOMAIN/conf/web" ]; then
  # Guardar copia de seguridad de la configuración actual
  if [ -f "/var/www/vhosts/$DOMAIN/conf/web/nginx.conf" ]; then
    cp /var/www/vhosts/$DOMAIN/conf/web/nginx.conf /var/www/vhosts/$DOMAIN/conf/web/nginx.conf.bak
    echo -e "\${BLUE}[INFO]\${NC} Copia de seguridad de nginx.conf creada."
  fi
  
  # Copiar la nueva configuración
  cp "$NGINX_CONF" /var/www/vhosts/$DOMAIN/conf/web/nginx.conf
  echo -e "\${GREEN}[OK]\${NC} Configuración de Nginx actualizada."
  
  # Reiniciar Nginx a través de Plesk si está disponible
  if command -v plesk >/dev/null 2>&1; then
    echo -e "\${BLUE}[INFO]\${NC} Reiniciando Nginx a través de Plesk..."
    plesk bin server_pref -u -nginx-restart -value true
  else
    echo -e "\${YELLOW}[AVISO]\${NC} Plesk no encontrado, intenta reiniciar Nginx manualmente."
  fi
else
  echo -e "\${YELLOW}[AVISO]\${NC} No se encontró el directorio de configuración de Nginx para este dominio."
  echo -e "La configuración de Nginx está disponible en: $NGINX_CONF"
  echo -e "Por favor instálala manualmente."
fi

# Corregir permisos
echo -e "\${BLUE}[INFO]\${NC} Corrigiendo permisos..."
chmod -R 755 "$APP_DIR/dialoom-frontend/dist" 2>/dev/null || true
chmod 755 "$APP_DIR/app.js"
chmod -R 755 "$APP_DIR/fallback"

echo -e "\${BLUE}[INFO]\${NC} Reiniciando la aplicación Node.js..."
cd "$APP_DIR"
if command -v pm2 >/dev/null 2>&1; then
  # Si PM2 está disponible, úsalo para gestionar el proceso
  pm2 restart app.js || pm2 start app.js
else
  # De lo contrario, sugerir reinicio desde Plesk
  echo -e "\${YELLOW}[AVISO]\${NC} PM2 no encontrado, reinicia la aplicación Node.js desde el panel de Plesk."
fi

echo -e "\${GREEN}[COMPLETADO]\${NC} Configuración instalada."
echo -e "\${BLUE}[INFO]\${NC} Por favor:"
echo "1. Reinicia la aplicación Node.js desde el panel de Plesk si no se ha hecho automáticamente"
echo "2. Accede a https://$DOMAIN para verificar"
echo "3. Si aún tienes problemas, accede a https://$DOMAIN/fallback para ver la página de diagnóstico"
EOF

chmod +x "$APP_DIR/install_config.sh"

echo -e "${GREEN}[OK]${NC} Script de instalación creado."

# 7. Ejecutar compilación de la aplicación React si existe
if [ -d "$FRONTEND_DIR" ] && [ -f "$FRONTEND_DIR/package.json" ]; then
  echo -e "${BLUE}[INFO]${NC} Recompilando la aplicación React..."
  cd "$FRONTEND_DIR"
  if npm run build; then
    echo -e "${GREEN}[OK]${NC} Aplicación compilada exitosamente."
  else
    echo -e "${RED}[ERROR]${NC} Error al compilar la aplicación."
  fi
else
  echo -e "${YELLOW}[AVISO]${NC} No se encontró el directorio de frontend o el archivo package.json."
fi

# 8. Mensaje final
echo -e "
${GREEN}==================================================${NC}
${GREEN}     CONFIGURACIÓN DE DIALOOM CON NGINX/SSL      ${NC}
${GREEN}==================================================${NC}

${BLUE}[INFO]${NC} Se han creado los siguientes archivos:
 - $APP_DIR/app.js (Servidor Node.js optimizado)
 - $NGINX_CONF (Configuración de Nginx)
 - $PROXY_PARAMS (Parámetros de proxy)
 - $APP_DIR/fallback/index.html (Página de fallback)
 - $APP_DIR/install_config.sh (Script de instalación)

${YELLOW}[ACCIÓN REQUERIDA]${NC} Para completar la instalación:

1. Ejecuta el script de instalación como root:
   $ sudo $APP_DIR/install_config.sh

2. Reinicia la aplicación Node.js desde el panel de Plesk

3. Accede a tu sitio:
   https://$DOMAIN

${BLUE}[SOLUCIÓN DE PROBLEMAS]${NC}
Si la página sigue en blanco:
- Verifica que Node.js está en ejecución (desde el panel de Plesk)
- Revisa los logs de Node.js
- Accede a https://$DOMAIN/fallback para ver la página de diagnóstico
"