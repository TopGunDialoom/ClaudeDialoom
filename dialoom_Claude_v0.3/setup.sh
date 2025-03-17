#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funciones de utilidad
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en la carpeta correcta
if [ ! -f "package.json" ]; then
  log_error "Este script debe ejecutarse desde la carpeta raíz del proyecto."
  exit 1
fi

# Comprobar versión de Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2)
MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1)

log_info "Detectada versión de Node.js: $NODE_VERSION"

if [ "$MAJOR_VERSION" -lt "16" ]; then
  log_warn "Se recomienda Node.js 16 o superior. La versión actual es $NODE_VERSION"
  read -p "¿Desea continuar de todos modos? (s/n): " CONTINUE
  if [ "$CONTINUE" != "s" ]; then
    log_info "Instalación abortada."
    exit 0
  fi
fi

# Verificar si .env existe
if [ ! -f ".env" ]; then
  log_info "Creando archivo .env desde .env.example"
  cp .env.example .env
  log_warn "Por favor, revise y ajuste los valores en el archivo .env"
else
  log_info "El archivo .env ya existe."
fi

# Instalar dependencias
log_info "Instalando dependencias. Esto puede tardar unos minutos..."
npm install

# Corregir posibles errores de construcción
log_info "Aplicando correcciones automáticas de código..."
chmod +x ./fix_build_errors.sh
./fix_build_errors.sh

# Construir el proyecto
log_info "Compilando el proyecto..."
npm run build

if [ $? -ne 0 ]; then
  log_error "Error al compilar el proyecto. Revise los mensajes de error."
  exit 1
else
  log_info "El proyecto se ha compilado correctamente."
fi

# Actualizar permisos
log_info "Actualizando permisos de archivos..."
chmod 755 ./dist/main.js

# Crear un archivo app.js para Plesk
cat > app.js << 'EOF'
require('./dist/main');
EOF
chmod 755 app.js

# Instrucciones finales
log_info "====================================================================="
log_info "Instalación completada con éxito."
log_info ""
log_info "Para iniciar el backend en modo producción:"
log_info "  npm run start:prod"
log_info ""
log_info "O configurar en Plesk:"
log_info "  - Documento raíz: /httpdocs"
log_info "  - Archivo de inicio: app.js"
log_info "====================================================================="
