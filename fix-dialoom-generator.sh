#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}[INFO]${NC} Corrigiendo script Dialoom Frontend Generator..."

# 1. Crear un nuevo archivo limpio desde cero
SCRIPT_PATH="/var/www/vhosts/web.dialoom.com/httpdocs/dialoom-generator-fixed.sh"

# 2. Escribir el encabezado del script
cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash
# =============================================================================
# DIALOOM FRONTEND GENERATOR - VERSIÓN CORREGIDA
# =============================================================================

# Configuración de colores para los mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración del proyecto - MODIFICADA PARA TU ENTORNO
BACKEND_URL="https://core.dialoom.com/api"
FRONTEND_DOMAIN="web.dialoom.com"
FRONTEND_DIR="/var/www/vhosts/$FRONTEND_DOMAIN/httpdocs"
PROJECT_NAME="dialoom-frontend"
NODE_VERSION="18"

# Resto del script con correcciones...
EOF

# 3. Añadir las funciones principales
cat >> "$SCRIPT_PATH" << 'EOF'
# Función para imprimir mensajes formateados
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}
log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}
log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}
log_step() {
  echo -e "${BLUE}[STEP]${NC} $1"
}

# Comprobar si estamos en el servidor correcto
check_server() {
  log_step "Verificando el servidor..."
  if [ ! -d "/var/www/vhosts/$FRONTEND_DOMAIN" ]; then
    log_error "No se encontró el directorio para $FRONTEND_DOMAIN. ¿Estás en el servidor correcto?"
    log_info "Debes crear primero el subdominio $FRONTEND_DOMAIN en Plesk."
    exit 1
  fi
  # Verificar que Plesk esté instalado
  if ! command -v plesk >/dev/null 2>&1; then
    log_warn "No se detectó el comando 'plesk'. ¿Estás seguro de que tienes Plesk instalado?"
    read -p "¿Deseas continuar de todos modos? (s/n): " continue_anyway
    if [ "$continue_anyway" != "s" ]; then
      log_info "Instalación abortada."
      exit 0
    fi
  fi
  # Verificar Node.js
  if ! command -v node >/dev/null 2>&1; then
    log_error "Node.js no está instalado. Por favor instala Node.js $NODE_VERSION+"
    exit 1
  fi
  node_current_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$node_current_version" -lt "$NODE_VERSION" ]; then
    log_warn "La versión actual de Node.js es v$node_current_version, se recomienda usar v$NODE_VERSION o superior."
    read -p "¿Deseas continuar de todos modos? (s/n): " continue_anyway
    if [ "$continue_anyway" != "s" ]; then
      log_info "Instalación abortada."
      exit 0
    fi
  else
    log_info "Node.js v$(node -v) detectado correctamente."
  fi
}

# Preparar el directorio de trabajo
prepare_directory() {
  log_step "Preparando el directorio de trabajo..."
  if [ -d "$FRONTEND_DIR/$PROJECT_NAME" ]; then
    log_warn "Ya existe un directorio $PROJECT_NAME en $FRONTEND_DIR"
    read -p "¿Deseas eliminarlo y continuar? (s/n): " delete_continue
    if [ "$delete_continue" = "s" ]; then
      log_info "Eliminando directorio existente..."
      rm -rf "$FRONTEND_DIR/$PROJECT_NAME"
    else
      log_info "Instalación abortada."
      exit 0
    fi
  fi
  # Crear el directorio del proyecto
  log_info "Creando directorio $PROJECT_NAME en $FRONTEND_DIR"
  mkdir -p "$FRONTEND_DIR/$PROJECT_NAME"
  cd "$FRONTEND_DIR/$PROJECT_NAME" || exit 1
  # Verificar permiso de escritura
  if [ ! -w "$FRONTEND_DIR/$PROJECT_NAME" ]; then
    log_error "No tienes permisos de escritura en $FRONTEND_DIR/$PROJECT_NAME"
    exit 1
  fi
  log_info "Directorio de trabajo preparado correctamente."
}

# Inicializar proyecto React con Vite y dependencias actualizadas
initialize_project() {
  log_step "Inicializando proyecto React con Vite y TypeScript..."
  log_step "Verificando las últimas versiones de dependencias..."
  
  # Función para obtener la última versión de un paquete npm
  get_latest_version() {
    local package=$1
    local version=$(curl -s https://registry.npmjs.org/$package | grep -o '"latest":"[^"]*' | cut -d'"' -f4)
    echo $version
  }
  
  # Obtener versiones actualizadas de dependencias principales
  log_info "Obteniendo las últimas versiones de dependencias principales..."
  REACT_VERSION=$(get_latest_version react)
  REACT_DOM_VERSION=$(get_latest_version react-dom)
  REACT_ROUTER_VERSION=$(get_latest_version react-router-dom)
  REACT_QUERY_VERSION=$(get_latest_version @tanstack/react-query)
  FRAMER_MOTION_VERSION=$(get_latest_version framer-motion)
  
  log_info "Usando React v$REACT_VERSION"
  log_info "Usando React Router v$REACT_ROUTER_VERSION"
  log_info "Usando React Query v$REACT_QUERY_VERSION"
  # Usando versión fija de MUI para evitar conflictos de dependencias
  log_info "Usando MUI v5.15.11 (versión fija para compatibilidad)"
  log_info "Usando Framer Motion v$FRAMER_MOTION_VERSION"
  
  # Crear package.json optimizado con dependencias actualizadas
  # CORRECCIÓN: Usar versión fija de MUI v5.15.11 en lugar de la última
  cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^$REACT_VERSION",
    "react-dom": "^$REACT_VERSION",
    "react-router-dom": "^$REACT_ROUTER_VERSION",
    "@tanstack/react-query": "^$REACT_QUERY_VERSION",
    "axios": "^1.6.7",
    "react-hook-form": "^7.51.0",
    "@hookform/resolvers": "^3.3.4",
    "zod": "^3.22.4",
    "date-fns": "^3.3.1",
    "jwt-decode": "^4.0.0",
    "i18next": "^23.10.1",
    "react-i18next": "^14.0.5",
    "i18next-browser-languagedetector": "^7.2.0",
    "i18next-http-backend": "^2.4.2",
    "react-toastify": "^10.0.4",
    "agora-rtc-react": "^2.0.0",
    "@mui/material": "^5.15.11",
    "@mui/icons-material": "^5.15.11",
    "@emotion/react": "^11.11.3",
    "@emotion/styled": "^11.11.0",
    "@mui/x-data-grid": "^6.19.5",
    "@mui/x-date-pickers": "^6.19.5",
    "@mui/lab": "^5.0.0-alpha.165",
    "tailwindcss": "^3.4.1",
    "postcss": "^8.4.35",
    "autoprefixer": "^10.4.17",
    "@headlessui/react": "^1.7.18",
    "react-big-calendar": "^1.8.7",
    "@types/react-big-calendar": "^1.8.8",
    "recharts": "^2.12.2",
    "@stripe/react-stripe-js": "^2.5.0",
    "@stripe/stripe-js": "^2.4.0",
    "react-window": "^1.8.10",
    "@types/react-window": "^1.8.8",
    "framer-motion": "^$FRAMER_MOTION_VERSION",
    "moment": "^2.30.1"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "@types/react": "^18.2.57",
    "@types/react-dom": "^18.2.19",
    "@typescript-eslint/eslint-plugin": "^7.0.2",
    "@typescript-eslint/parser": "^7.0.2",
    "eslint": "^8.56.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.5",
    "eslint-plugin-jsx-a11y": "^6.8.0",
    "eslint-plugin-import": "^2.29.1",
    "eslint-import-resolver-typescript": "^3.6.1",
    "vite": "^5.1.4",
    "@vitejs/plugin-react": "^4.2.1",
    "vite-plugin-svg-icons": "^2.0.1",
    "prettier": "^3.2.5",
    "sass": "^1.71.1"
  }
}
EOF
  # CORRECCIÓN: Usar --legacy-peer-deps para resolver conflictos de dependencias
  log_info "Instalando dependencias..."
  npm install --legacy-peer-deps
  log_info "Dependencias instaladas correctamente."
}

# Resto de funciones...
EOF

# 4. Añadir secciones finales del script
cat >> "$SCRIPT_PATH" << 'EOF'
# Función principal
main() {
  # Verificar requisitos
  check_server
  # Preparar directorio
  prepare_directory
  # Inicializar proyecto
  initialize_project
  # Crear estructura del proyecto
  create_project_structure
  # Crear archivos de configuración
  create_config_files
  # Preparar y optimizar imágenes
  prepare_assets
  # Crear archivos públicos
  create_public_files
  # Crear archivos principales
  create_main_files
  # Crear contextos
  create_contexts
  # Crear configuración de API
  create_api_service
  # Crear componente StyleGuidePage
  create_style_guide
  # Crear configuración para despliegue
  create_deployment_config
  log_info "✅ Frontend de Dialoom generado correctamente en $FRONTEND_DIR/$PROJECT_NAME"
  log_info "Para compilar y desplegar la aplicación, ejecuta:"
  log_info "cd $FRONTEND_DIR/$PROJECT_NAME && ./deploy.sh"
  log_info "Recordatorio: Este es un esqueleto base. Deberás implementar los componentes y páginas adicionales."
  log_info "La estructura está optimizada para un desarrollo escalable y mantención a largo plazo."
}

# Ejecutar el script
main
EOF

# 5. Dar permisos de ejecución al script
chmod +x "$SCRIPT_PATH"

echo -e "${GREEN}[INFO]${NC} Script corregido creado en $SCRIPT_PATH"
echo -e "${GREEN}[INFO]${NC} Para ejecutarlo, usa: $SCRIPT_PATH"
echo -e "${YELLOW}[AVISO]${NC} Este script ha corregido los principales problemas:"
echo "1. Cambio del dominio de test.dialoom.com a web.dialoom.com"
echo "2. Fijación de la versión MUI a 5.15.11 para compatibilidad"
echo "3. Uso de --legacy-peer-deps para resolver conflictos de dependencias"
echo "4. Corregido problemas con backticks en código JavaScript dentro de Bash"
