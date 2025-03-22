#!/bin/bash
# Instalar configuración de proxy Nginx y reiniciar servicios

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[INFO]${NC} Instalando configuración para Dialoom..."

# Copiar archivos de configuración
echo -e "${BLUE}[INFO]${NC} Copiando configuración de Nginx..."
cp "/tmp/proxy_params.63758" /var/www/vhosts/web.dialoom.com/conf/proxy_params

# Verificar si debemos usar la nueva configuración de Nginx
if [ -d "/var/www/vhosts/web.dialoom.com/conf/web" ]; then
  # Guardar copia de seguridad de la configuración actual
  if [ -f "/var/www/vhosts/web.dialoom.com/conf/web/nginx.conf" ]; then
    cp /var/www/vhosts/web.dialoom.com/conf/web/nginx.conf /var/www/vhosts/web.dialoom.com/conf/web/nginx.conf.bak
    echo -e "${BLUE}[INFO]${NC} Copia de seguridad de nginx.conf creada."
  fi
  
  # Copiar la nueva configuración
  cp "/tmp/nginx.conf.63758" /var/www/vhosts/web.dialoom.com/conf/web/nginx.conf
  echo -e "${GREEN}[OK]${NC} Configuración de Nginx actualizada."
  
  # Reiniciar Nginx a través de Plesk si está disponible
  if command -v plesk >/dev/null 2>&1; then
    echo -e "${BLUE}[INFO]${NC} Reiniciando Nginx a través de Plesk..."
    plesk bin server_pref -u -nginx-restart -value true
  else
    echo -e "${YELLOW}[AVISO]${NC} Plesk no encontrado, intenta reiniciar Nginx manualmente."
  fi
else
  echo -e "${YELLOW}[AVISO]${NC} No se encontró el directorio de configuración de Nginx para este dominio."
  echo -e "La configuración de Nginx está disponible en: /tmp/nginx.conf.63758"
  echo -e "Por favor instálala manualmente."
fi

# Corregir permisos
echo -e "${BLUE}[INFO]${NC} Corrigiendo permisos..."
chmod -R 755 "/var/www/vhosts/web.dialoom.com/httpdocs/dialoom-frontend/dist" 2>/dev/null || true
chmod 755 "/var/www/vhosts/web.dialoom.com/httpdocs/app.js"
chmod -R 755 "/var/www/vhosts/web.dialoom.com/httpdocs/fallback"

echo -e "${BLUE}[INFO]${NC} Reiniciando la aplicación Node.js..."
cd "/var/www/vhosts/web.dialoom.com/httpdocs"
if command -v pm2 >/dev/null 2>&1; then
  # Si PM2 está disponible, úsalo para gestionar el proceso
  pm2 restart app.js || pm2 start app.js
else
  # De lo contrario, sugerir reinicio desde Plesk
  echo -e "${YELLOW}[AVISO]${NC} PM2 no encontrado, reinicia la aplicación Node.js desde el panel de Plesk."
fi

echo -e "${GREEN}[COMPLETADO]${NC} Configuración instalada."
echo -e "${BLUE}[INFO]${NC} Por favor:"
echo "1. Reinicia la aplicación Node.js desde el panel de Plesk si no se ha hecho automáticamente"
echo "2. Accede a https://web.dialoom.com para verificar"
echo "3. Si aún tienes problemas, accede a https://web.dialoom.com/fallback para ver la página de diagnóstico"
