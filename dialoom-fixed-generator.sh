#!/bin/bash
# =============================================================================
# DIALOOM FRONTEND GENERATOR - VERSIÓN OPTIMIZADA MEJORADA
# =============================================================================

# (Rest of the script header and initial functions are unchanged)

# Configuración de colores para los mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración del proyecto
BACKEND_URL="https://core.dialoom.com/api"
FRONTEND_DOMAIN="web.dialoom.com"
FRONTEND_DIR="/var/www/vhosts/$FRONTEND_DOMAIN/httpdocs"
PROJECT_NAME="dialoom-frontend"
NODE_VERSION="18"

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
  REACT_QUERY_VERSION=$(get_latest_version '@tanstack/react-query')
  MUI_VERSION=$(get_latest_version @mui/material)
  FRAMER_MOTION_VERSION=$(get_latest_version framer-motion)
  
  log_info "Usando React v$REACT_VERSION"
  log_info "Usando React Router v$REACT_ROUTER_VERSION"
  log_info "Usando React Query v$REACT_QUERY_VERSION"
  log_info "Usando MUI v$MUI_VERSION"
  log_info "Usando Framer Motion v$FRAMER_MOTION_VERSION"
  
  # Crear package.json optimizado con dependencias actualizadas
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
    "@mui/material": "^$MUI_VERSION",
    "@mui/icons-material": "^$MUI_VERSION",
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
  # Usar npm para instalar dependencias
  log_info "Instalando dependencias..."
  npm install --legacy-peer-deps
  log_info "Dependencias instaladas correctamente."
}



# Crear estructura de carpetas del proyecto (basada en features)
create_project_structure() {
  log_step "Creando estructura de carpetas del proyecto..."
  # Carpetas principales
  mkdir -p public/locales/{en,es,ca,de,fr,nl,it}
  mkdir -p public/assets/images/{logos,icons,flags,payment,backgrounds,avatars}
  # Estructura basada en features
  mkdir -p src/assets/{icons,images}
  # Carpetas de características
  mkdir -p src/features/auth/{components,hooks,services,types,utils,pages}
  mkdir -p src/features/dashboard/{components,hooks,services,types,pages}
  mkdir -p src/features/hosts/{components,hooks,services,types,pages}
  mkdir -p src/features/reservations/{components,hooks,services,types,pages}
  mkdir -p src/features/calls/{components,hooks,services,types,pages}
  mkdir -p src/features/payments/{components,hooks,services,types,pages}
  mkdir -p src/features/profile/{components,hooks,services,types,pages}
  mkdir -p src/features/admin/{components,hooks,services,types,pages}
  mkdir -p src/features/admin/pages/{theme,users,hosts,content,payments,dashboard,reports,achievements}
  mkdir -p src/features/error/pages
  # Carpetas compartidas
  mkdir -p src/shared/components/{common,layout,ui,forms,cards,modals}
  mkdir -p src/shared/hooks
  mkdir -p src/shared/services
  mkdir -p src/shared/utils
  mkdir -p src/shared/types
  mkdir -p src/shared/contexts
  # Rutas y configuración
  mkdir -p src/routes
  mkdir -p src/config
  mkdir -p src/i18n
  mkdir -p src/api
  mkdir -p src/styles
  log_info "Estructura de carpetas creada correctamente."

  # ------ Create Example Component Files ------
  # We'll create LoginPage, DashboardPage, and AdminUsersPage as examples.

  # src/features/auth/pages/LoginPage.tsx
  cat > src/features/auth/pages/LoginPage.tsx << 'EOF'
import React from 'react';
import { Box, Typography } from '@mui/material';

const LoginPage: React.FC = () => {
  return (
    <Box>
      <Typography variant="h1">Login Page</Typography>
      {/* Add your login form and logic here */}
    </Box>
  );
};

export default LoginPage;
EOF

  # src/features/dashboard/pages/DashboardPage.tsx
  cat > src/features/dashboard/pages/DashboardPage.tsx << 'EOF'
import React from 'react';
import { Box, Typography } from '@mui/material';

const DashboardPage: React.FC = () => {
  return (
    <Box>
      <Typography variant="h1">Dashboard Page</Typography>
      {/* Add your dashboard content here */}
    </Box>
  );
};

export default DashboardPage;
EOF

  # src/features/admin/pages/users/AdminUsersPage.tsx
  cat > src/features/admin/pages/users/AdminUsersPage.tsx << 'EOF'
import React from 'react';
import { Box, Typography } from '@mui/material';

const AdminUsersPage: React.FC = () => {
  return (
    <Box>
      <Typography variant="h1">Admin Users Page</Typography>
      {/* Add your admin user management content here */}
    </Box>
  );
};

export default AdminUsersPage;
EOF

# --- Continue with the rest of your script ---

}


# Preparar y optimizar imágenes
prepare_assets() {
  log_step "Preparando archivos de assets..."
  # Crear estructura de directorios para los assets
  mkdir -p public/assets/images/logos
  mkdir -p public/assets/images/icons
  mkdir -p public/assets/images/flags
  mkdir -p public/assets/images/payment
  mkdir -p public/assets/images/backgrounds
  mkdir -p public/assets/images/avatars
  
  # Verificar si existe directorio de imágenes de referencia
  if [ -d "reference_images" ]; then
    log_info "Copiando imágenes de referencia..."
    # Logos
    cp -f reference_images/dialoom-logo.* public/assets/images/logos/ 2>/dev/null || true
    cp -f reference_images/*logo* public/assets/images/logos/ 2>/dev/null || true
    # Iconos
    cp -f reference_images/*icon* public/assets/images/icons/ 2>/dev/null || true
    # Banderas
    cp -f reference_images/*flag* public/assets/images/flags/ 2>/dev/null || true
    # Métodos de pago
    cp -f reference_images/mastercard.* public/assets/images/payment/ 2>/dev/null || true
    cp -f reference_images/maestro.* public/assets/images/payment/ 2>/dev/null || true
    cp -f reference_images/visa.* public/assets/images/payment/ 2>/dev/null || true
    # Fondos
    cp -f reference_images/*background* public/assets/images/backgrounds/ 2>/dev/null || true
    # Avatares
    cp -f reference_images/*avatar* public/assets/images/avatars/ 2>/dev/null || true
  else
    log_info "Generando assets por defecto..."
    # Crear SVG del logo Dialoom basado en las imágenes
    cat > public/assets/images/logos/dialoom-logo.svg << 'EOF'
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 8C8.68629 8 6 10.6863 6 14V34C6 37.3137 8.68629 40 12 40H28C31.3137 40 34 37.3137 34 34V28L42 36V12L34 20V14C34 10.6863 31.3137 8 28 8H12Z" fill="#1A7A8B"/>
</svg>
EOF
    # Crear SVG del icon para llamadas
    cat > public/assets/images/icons/calls-icon.svg << 'EOF'
<svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect width="24" height="24" rx="4" fill="#1A7A8B" />
<path d="M8 8V22H22V8H8ZM10 10H20V20H10V10Z" fill="white"/>
<path d="M28 12V26H14V28H30V12H28Z" fill="#1A7A8B"/>
</svg>
EOF
    # Crear SVG para el icono de disponibilidad
    cat > public/assets/images/icons/availability-icon.svg << 'EOF'
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M36 8H12C9.79086 8 8 9.79086 8 12V36C8 38.2091 9.79086 40 12 40H36C38.2091 40 40 38.2091 40 36V12C40 9.79086 38.2091 8 36 8Z" stroke="#1A7A8B" stroke-width="2"/>
<path d="M16 4V12" stroke="#1A7A8B" stroke-width="2" stroke-linecap="round"/>
<path d="M32 4V12" stroke="#1A7A8B" stroke-width="2" stroke-linecap="round"/>
<path d="M8 20H40" stroke="#1A7A8B" stroke-width="2"/>
<circle cx="24" cy="30" r="2" fill="#1A7A8B"/>
<circle cx="32" cy="30" r="2" fill="#1A7A8B"/>
<circle cx="16" cy="30" r="2" fill="#1A7A8B"/>
</svg>
EOF
    # Crear avatar de ejemplo
    cat > public/assets/images/avatars/default-avatar.svg << 'EOF'
<svg width="200" height="200" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="100" cy="100" r="100" fill="#1A7A8B"/>
  <circle cx="100" cy="85" r="35" fill="white"/>
  <path d="M100 130C75.1472 130 55 150.147 55 175H145C145 150.147 124.853 130 100 130Z" fill="white"/>
</svg>
EOF
  fi
  
  # Si no se encontraron imágenes de banderas, crear algunas por defecto
  if [ ! -f "public/assets/images/flags/en.svg" ]; then
    # Crear bandera de UK/USA como fallback para inglés
    cat > public/assets/images/flags/en.svg << 'EOF'
<svg width="28" height="20" viewBox="0 0 28 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect width="28" height="20" fill="#012169"/>
<path d="M28 0H0V20H28V0Z" fill="#012169"/>
<path d="M0 0V2.22L24.89 20H28V17.78L3.11 0H0Z" fill="white"/>
<path d="M28 0V2.22L3.11 20H0V17.78L24.89 0H28Z" fill="white"/>
<path d="M11.2 0V20H16.8V0H11.2Z" fill="white"/>
<path d="M0 6.67V13.33H28V6.67H0Z" fill="white"/>
<path d="M12.6 0V20H15.4V0H12.6Z" fill="#C8102E"/>
<path d="M0 8V12H28V8H0Z" fill="#C8102E"/>
<path d="M28 0V1.67L5.44 20H0V18.33L22.56 0H28Z" fill="#C8102E"/>
<path d="M0 0V1.67L22.56 20H28V18.33L5.44 0H0Z" fill="#C8102E"/>
</svg>
EOF
    # Crear bandera de España
    cat > public/assets/images/flags/es.svg << 'EOF'
<svg width="28" height="20" viewBox="0 0 28 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect width="28" height="20" fill="#AA151B"/>
<rect y="5" width="28" height="10" fill="#F1BF00"/>
</svg>
EOF
    # Crear bandera de Cataluña
    cat > public/assets/images/flags/ca.svg << 'EOF'
<svg width="28" height="20" viewBox="0 0 28 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect width="28" height="20" fill="#FCDD09"/>
<path d="M0 0H28V2.5H0V0Z" fill="#DA121A"/>
<path d="M0 5H28V7.5H0V5Z" fill="#DA121A"/>
<path d="M0 10H28V12.5H0V10Z" fill="#DA121A"/>
<path d="M0 15H28V17.5H0V15Z" fill="#DA121A"/>
</svg>
EOF
  fi
  
  # Crear íconos para métodos de pago si no existen
  if [ ! -f "public/assets/images/payment/visa.svg" ]; then
    cat > public/assets/images/payment/visa.svg << 'EOF'
<svg width="48" height="32" viewBox="0 0 48 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="48" height="32" rx="4" fill="white"/>
  <path d="M18.5 20.5H15L17 11.5H20.5L18.5 20.5Z" fill="#00579F"/>
  <path d="M29.5 11.75C28.8 11.5 27.75 11.25 26.5 11.25C24 11.25 22 12.5 22 14.5C22 16 23.5 16.75 24.5 17.25C25.5 17.75 26 18 26 18.5C26 19.25 25 19.5 24 19.5C22.75 19.5 22 19.25 21 19L20.5 18.75L20 21.25C20.75 21.5 22 21.75 23.25 21.75C26 21.75 28 20.5 28 18.25C28 17 27 16.25 25.5 15.5C24.5 15 24 14.75 24 14.25C24 13.75 24.5 13.25 25.5 13.25C26.5 13.25 27.25 13.5 27.75 13.75L28.25 14L28.75 11.75H29.5Z" fill="#00579F"/>
  <path d="M32 11.5H34L31.5 20.5H29.5L32 11.5Z" fill="#00579F"/>
  <path d="M37 11.5L34.5 18L34.25 17.25C33.75 16 32 14.5 30 13.75L32.5 20.5H35L39 11.5H37Z" fill="#00579F"/>
</svg>
EOF
    cat > public/assets/images/payment/mastercard.svg << 'EOF'
<svg width="48" height="32" viewBox="0 0 48 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="48" height="32" rx="4" fill="white"/>
  <circle cx="18" cy="16" r="8" fill="#EB001B"/>
  <circle cx="30" cy="16" r="8" fill="#F79E1B"/>
  <path fill-rule="evenodd" clip-rule="evenodd" d="M24 21.5858C25.6569 19.9289 25.6569 17.0711 24 15.4142C22.3431 13.7574 19.4853 13.7574 17.8284 15.4142C16.1716 17.0711 16.1716 19.9289 17.8284 21.5858C19.4853 23.2426 22.3431 23.2426 24 21.5858Z" fill="#FF5F00"/>
</svg>
EOF
  fi
  
  log_info "Assets preparados correctamente."
}

# Configurar archivos principales del proyecto
create_config_files() {
  log_step "Creando archivos de configuración del proyecto..."
  # Crear tsconfig.json optimizado
  cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "noFallthroughCasesInSwitch": true,
    "allowSyntheticDefaultImports": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@features/*": ["./src/features/*"],
      "@shared/*": ["./src/shared/*"],
      "@api/*": ["./src/api/*"],
      "@config/*": ["./src/config/*"],
      "@styles/*": ["./src/styles/*"],
      "@assets/*": ["./src/assets/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF
  # Crear tsconfig.node.json
  cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF
  # Crear vite.config.ts optimizado con mejor soporte para assets
  cat > vite.config.ts << 'EOF'
import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'
import { createSvgIconsPlugin } from 'vite-plugin-svg-icons'

# https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  # Cargar variables de entorno según el modo
  const env = loadEnv(mode, process.cwd(), '')
  return {
    plugins: [
      react(),
      # Plugin para generar sprites SVG automáticamente
      createSvgIconsPlugin({
        iconDirs: [path.resolve(process.cwd(), 'src/assets/icons')],
        symbolId: 'icon-[dir]-[name]',
      }),
    ],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
        '@features': path.resolve(__dirname, './src/features'),
        '@shared': path.resolve(__dirname, './src/shared'),
        '@api': path.resolve(__dirname, './src/api'),
        '@config': path.resolve(__dirname, './src/config'),
        '@styles': path.resolve(__dirname, './src/styles'),
        '@assets': path.resolve(__dirname, './src/assets')
      },
    },
    server: {
      port: 3000,
      host: true,
      proxy: {
        # Proxy API requests para desarrollo local
        '/api': {
          target: env.VITE_API_URL || 'https://core.dialoom.com/api',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, '')
        }
      }
    },
    build: {
      sourcemap: mode !== 'production',
      rollupOptions: {
        output
        {
          manualChunks: {
            'react-vendor': ['react', 'react-dom', 'react-router-dom'],
            'mui-vendor': ['@mui/material', '@mui/icons-material', '@emotion/react', '@emotion/styled'],
            'chart-vendor': ['recharts'],
            'form-vendor': ['react-hook-form', '@hookform/resolvers', 'zod'],
            'i18n-vendor': ['i18next', 'react-i18next'],
            'animation-vendor': ['framer-motion'],
          }
        }
      },
      # Optimizaciones para imágenes
      assetsInlineLimit: 4096, # 4kb
      chunkSizeWarningLimit: 1000, # 1mb
    },
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: '@import "@/styles/mixins.scss";',
        },
      },
    },
    optimizeDeps: {
      include: ['react', 'react-dom', 'react-router-dom'],
    },
  }
})
EOF
  # Crear .gitignore
  cat > .gitignore << 'EOF'
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*
node_modules
dist
dist-ssr
*.local
# Editor directories and files
.vscode/*
!.vscode/extensions.json
.idea
.DS_Store
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?
# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
# Testing
coverage
EOF
  # Crear .prettierrc
  cat > .prettierrc << 'EOF'
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "arrowParens": "avoid",
  "endOfLine": "auto"
}
EOF
  # Crear .eslintrc.cjs mejorado
  cat > .eslintrc.cjs << 'EOF'
module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
    'plugin:jsx-a11y/recommended', # Accesibilidad
    'plugin:import/recommended',
    'plugin:import/typescript',
  ],
  ignorePatterns: ['dist', '.eslintrc.cjs'],
  parser: '@typescript-eslint/parser',
  plugins: ['react-refresh', 'jsx-a11y', 'import'],
  rules: {
    'react-refresh/only-export-components': [
      'warn',
      { allowConstantExport: true },
    ],
    '@typescript-eslint/no-unused-vars': ['warn', {
      argsIgnorePattern: '^_',
      varsIgnorePattern: '^_',
    }],
    'jsx-a11y/alt-text': 'error', # Garantizar que todas las imágenes tienen alt
    'jsx-a11y/click-events-have-key-events': 'warn',
    'import/order': ['warn', {
      'groups': [
        'builtin', # Node.js built-in modules
        'external', # Módulos npm instalados
        'internal', # Importaciones internas de rutas alias
        'parent', # Importaciones desde la carpeta padre
        'sibling', # Importaciones desde el mismo nivel
        'index', # Importaciones desde el índice de la carpeta actual
        'object', # Importaciones de objetos de TypeScript
        'type', # Importaciones de tipos
      ],
      'pathGroups': [
        {
          'pattern': 'react',
          'group': 'builtin',
          'position': 'before'
        },
        {
          'pattern': '@/**',
          'group': 'internal',
          'position': 'after'
        }
      ],
      'alphabetize': {
        'order': 'asc',
        'caseInsensitive': true
      },
      'newlines-between': 'always'
    }],
  },
  settings: {
    'import/resolver': {
      'typescript': {}, # usa tsconfig.json para resolver rutas
      'node': {
        'extensions': ['.js', '.jsx', '.ts', '.tsx']
      }
    }
  }
}
EOF
  # Crear .env.development
  cat > .env.development << EOF
VITE_API_URL=$BACKEND_URL
VITE_AGORA_APP_ID=your_agora_app_id
VITE_STRIPE_PUBLIC_KEY=your_stripe_public_key
VITE_ENVIRONMENT=development
EOF
  # Crear .env.production
  cat > .env.production << EOF
VITE_API_URL=$BACKEND_URL
VITE_AGORA_APP_ID=your_agora_app_id
VITE_STRIPE_PUBLIC_KEY=your_stripe_public_key
VITE_ENVIRONMENT=production
EOF
  # Crear postcss.config.js
  cat > postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF
  # Crear tailwind.config.js optimizado
  cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          light: 'var(--color-primary-light)',
          main: 'var(--color-primary-main)',
          dark: 'var(--color-primary-dark)',
        },
        secondary: {
          light: 'var(--color-secondary-light)',
          main: 'var(--color-secondary-main)',
          dark: 'var(--color-secondary-dark)',
        },
        background: 'var(--color-background)',
        surface: 'var(--color-surface)',
        error: 'var(--color-error)',
        success: 'var(--color-success)',
        warning: 'var(--color-warning)',
        info: 'var(--color-info)',
      },
      fontFamily: {
        sans: 'var(--font-family)',
        heading: 'var(--heading-font-family)',
      },
      borderRadius: {
        DEFAULT: 'var(--border-radius)',
      },
      screens: {
        xs: '480px',
        sm: '600px',
        md: '960px',
        lg: '1280px',
        xl: '1920px',
      },
    },
  },
  plugins: [],
  # Configuración para asegurarse que Tailwind no sobrescribe los estilos de MUI
  corePlugins: {
    preflight: false,
  },
  important: '#root', # Ayuda a que Tailwind no entre en conflicto con MUI
}
EOF
  # Crear archivo de tipos común
  cat > src/vite-env.d.ts << 'EOF'
/// <reference types="vite/client" />
interface ImportMetaEnv {
  readonly VITE_API_URL: string
  readonly VITE_AGORA_APP_ID: string
  readonly VITE_STRIPE_PUBLIC_KEY: string
  readonly VITE_ENVIRONMENT: string
}
interface ImportMeta {
  readonly env: ImportMetaEnv
}
EOF
  
  # Crear archivo mixins.scss para configuración global de SCSS
  mkdir -p src/styles
  cat > src/styles/mixins.scss << 'EOF'
# Variables globales de SCSS
$primary-color: var(--color-primary-main);
$secondary-color: var(--color-secondary-main);
$border-radius: var(--border-radius);

# Mixins para responsive design
@mixin mobile {
  @media (max-width: 599px) {
    @content;
  }
}

@mixin tablet {
  @media (min-width: 600px) and (max-width: 959px) {
    @content;
  }
}

@mixin desktop {
  @media (min-width: 960px) {
    @content;
  }
}

# Mixins para flexbox
@mixin flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}

@mixin flex-between {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

# Mixins para animaciones
@mixin fadeIn($duration: 0.3s) {
  animation: fadeIn $duration ease-in-out;
  
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
}

@mixin slideIn($direction: 'left', $distance: 20px, $duration: 0.3s) {
  $start-x: 0;
  $start-y: 0;
  
  @if $direction == 'left' {
    $start-x: -$distance;
  } @else if $direction == 'right' {
    $start-x: $distance;
  } @else if $direction == 'top' {
    $start-y: -$distance;
  } @else if $direction == 'bottom' {
    $start-y: $distance;
  }
  
  animation: slideIn $duration ease-out;
  
  @keyframes slideIn {
    from {
      opacity: 0;
      transform: translate($start-x, $start-y);
    }
    to {
      opacity: 1;
      transform: translate(0, 0);
    }
  }
}

# Mixin para sombras
@mixin shadow($level: 1) {
  @if $level == 1 {
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  } @else if $level == 2 {
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
  } @else if $level == 3 {
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
  }
}
EOF
  
  log_info "Archivos de configuración creados correctamente."
}

# Crear archivos públicos
create_public_files() {
  log_step "Creando archivos públicos..."
  # Crear index.html con SEO optimizado
  cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/assets/images/logos/dialoom-logo.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Dialoom - Conectando clientes con mentores profesionales. Reserva sesiones con expertos y mejora tus habilidades." />
    <meta name="keywords" content="mentores, reservas online, aprendizaje, coaching, desarrollo profesional" />
    <meta name="theme-color" content="#1A7A8B" />
    <meta property="og:title" content="Dialoom - Plataforma de Mentores" />
    <meta property="og:description" content="Conecta con mentores profesionales y reserva sesiones personalizadas." />
    <meta property="og:type" content="website" />
    <meta property="og:url" content="https://web.dialoom.com" />
    <meta property="og:image" content="https://web.dialoom.com/assets/images/og-image.jpg" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <title>Dialoom - Plataforma de Mentores</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF
  # Crear favicon.ico placeholder
  cp -f public/assets/images/logos/dialoom-logo.svg public/favicon.ico 2>/dev/null || touch public/favicon.ico
  # Crear manifest.json para PWA
  cat > public/manifest.json << 'EOF'
{
  "short_name": "Dialoom",
  "name": "Dialoom - Plataforma de Mentores",
  "icons": [
    {
      "src": "favicon.ico",
      "sizes": "64x64 32x32 24x24 16x16",
      "type": "image/x-icon"
    },
    {
      "src": "assets/images/logos/dialoom-logo-192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "assets/images/logos/dialoom-logo-512.png",
      "type": "image/png",
      "sizes": "512x512"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#1A7A8B",
  "background_color": "#ffffff"
}
EOF
  # Crear robots.txt
  cat > public/robots.txt << 'EOF'
User-agent: *
Allow: /
Sitemap: https://web.dialoom.com/sitemap.xml
EOF
  # Crear archivos de traducción principales (archivo completo solo para inglés)
  # English translations (versión completa)
  cat > public/locales/en/translation.json << 'EOF'
{
  "common": {
    "appName": "Dialoom",
    "loading": "Loading...",
    "error": "Error",
    "success": "Success",
    "cancel": "Cancel",
    "save": "Save",
    "edit": "Edit",
    "delete": "Delete",
    "confirm": "Confirm",
    "back": "Back",
    "next": "Next",
    "submit": "Submit",
    "search": "Search",
    "filter": "Filter",
    "all": "All",
    "yes": "Yes",
    "no": "No",
    "ok": "OK",
    "actions": "Actions",
    "status": "Status",
    "details": "Details",
    "close": "Close",
    "noData": "No data available",
    "viewAll": "View All",
    "learnMore": "Learn More",
    "readMore": "Read More",
    "contactUs": "Contact Us",
    "goToHome": "Go to Home",
    "termsAndConditions": "Terms and Conditions",
    "privacyPolicy": "Privacy Policy",
    "allRightsReserved": "All rights reserved",
    "day": "Day",
    "week": "Week",
    "month": "Month",
    "today": "Today",
    "previous": "Previous",
    "date": "Date",
    "time": "Time",
    "event": "Event",
    "agenda": "Agenda"
  },
  "auth": {
    "login": "Login",
    "register": "Register",
    "logout": "Logout",
    "email": "Email",
    "password": "Password",
    "confirmPassword": "Confirm Password",
    "firstName": "First Name",
    "lastName": "Last Name",
    "forgotPassword": "Forgot Password?",
    "dontHaveAccount": "Don't have an account?",
    "alreadyHaveAccount": "Already have an account?",
    "signUp": "Sign Up",
    "signIn": "Sign In",
    "socialLogin": "Or continue with",
    "loginSuccess": "Login successful",
    "registerSuccess": "Registration successful",
    "logoutSuccess": "Logout successful",
    "passwordRecovery": "Password Recovery",
    "passwordReset": "Password Reset",
    "emailSent": "Email sent with recovery instructions",
    "passwordResetSuccess": "Password has been reset successfully",
    "verifyAccount": "Verify Account",
    "accountVerified": "Account verified successfully",
    "invalidCredentials": "Invalid email or password",
    "requiredField": "This field is required",
    "invalidEmail": "Invalid email address",
    "passwordTooShort": "Password must be at least 8 characters",
    "passwordsDontMatch": "Passwords don't match",
    "passwordMustContain": "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character",
    "enterNewPassword": "Enter new password",
    "confirmNewPassword": "Confirm new password",
    "twoFactorAuth": "Two-Factor Authentication",
    "enterCode": "Enter the code from your authenticator app",
    "setupTwoFactor": "Setup Two-Factor Authentication",
    "disableTwoFactor": "Disable Two-Factor Authentication",
    "twoFactorEnabled": "Two-Factor Authentication Enabled",
    "twoFactorDisabled": "Two-Factor Authentication Disabled",
    "scanQrCode": "Scan this QR code with your authenticator app",
    "enterVerificationCode": "Enter verification code",
    "verifyCode": "Verify Code",
    "sessionExpired": "Your session has expired. Please login again."
  },
  "navigation": {
    "dashboard": "Dashboard",
    "hosts": "Mentors",
    "reservations": "Reservations",
    "schedule": "Schedule",
    "calls": "Calls",
    "payments": "Payments",
    "profile": "Profile",
    "settings": "Settings",
    "admin": "Admin",
    "logout": "Logout",
    "home": "Home",
    "about": "About",
    "contact": "Contact",
    "faq": "FAQ"
  },
  "dashboard": {
    "welcome": "Welcome, Frontend3!",
    "upcomingReservations": "Upcoming Reservations",
    "recentReservations": "Recent Reservations",
    "noUpcomingReservations": "No upcoming reservations",
    "noRecentReservations": "No recent reservations",
    "viewAll": "View All",
    "quickActions": "Quick Actions",
    "findMentor": "Find Mentor",
    "scheduleCall": "Schedule Call",
    "viewPayments": "View Payments",
    "statistics": "Statistics",
    "totalReservations": "Total Reservations",
    "completedCalls": "Completed Calls",
    "totalEarnings": "Total Earnings",
    "totalSpent": "Total Spent",
    "achievements": "Achievements",
    "noAchievements": "No achievements yet",
    "viewAchievements": "View Achievements",
    "recentActivity": "Recent Activity",
    "noActivity": "No recent activity",
    "today": "Today",
    "tomorrow": "Tomorrow",
    "thisWeek": "This Week",
    "upcomingCall": "Upcoming Call",
    "completedSession": "Completed Session",
    "getStarted": "Get Started",
    "scheduleYourFirstCall": "Schedule your first call",
    "completeYourProfile": "Complete your profile",
    "becomeAMentor": "Become a mentor"
  },
  "hosts": {
    "findMentor": "Find a Mentor",
    "featuredMentors": "Featured Mentors",
    "allMentors": "All Mentors",
    "sortBy": "Sort By",
    "filterBy": "Filter By",
    "rating": "Rating",
    "price": "Price",
    "availability": "Availability",
    "specialties": "Specialties",
    "languages": "Languages",
    "bookSession": "Book Session",
    "viewProfile": "View Profile",
    "hourlyRate": "Hourly Rate",
    "noMentorsFound": "No mentors found matching your criteria",
    "becomeHost": "Become a Mentor",
    "hostProfile": "Mentor Profile",
    "bio": "Bio",
    "experience": "Experience",
    "reviews": "Reviews",
    "noReviews": "No reviews yet",
    "writeReview": "Write a Review",
    "reviewSubmitted": "Review submitted successfully",
    "editProfile": "Edit Profile",
    "uploadPhoto": "Upload Photo",
    "uploadBanner": "Upload Banner",
    "setAvailability": "Set Availability",
    "manageAvailability": "Manage Availability",
    "availabilityUpdated": "Availability updated successfully",
    "manageSpecialties": "Manage Specialties",
    "specialtiesUpdated": "Specialties updated successfully",
    "verified": "Verified",
    "featured": "Featured",
    "topRated": "Top Rated",
    "howItWorks": "How It Works",
    "aboutTheMentor": "About the Mentor",
    "contactMentor": "Contact Mentor",
    "mentorSince": "Mentor since",
    "totalSessions": "Total Sessions",
    "responseRate": "Response Rate",
    "expertIn": "Expert in",
    "location": "Location",
    "similar": "Similar Mentors",
    "showMore": "Show More",
    "showLess": "Show Less"
  },
  "reservations": {
    "book": "Book a Session",
    "upcoming": "Upcoming Sessions",
    "past": "Past Sessions",
    "noUpcoming": "No upcoming sessions",
    "noPast": "No past sessions",
    "bookWith": "Book a session with Frontend3",
    "selectDate": "Select Date",
    "selectTime": "Select Time",
    "duration": "Duration",
    "totalPrice": "Total Price",
    "paymentMethod": "Payment Method",
    "bookingSuccess": "Booking successful!",
    "joinCall": "Join Call",
    "reschedule": "Reschedule",
    "cancel": "Cancel Reservation",
    "confirmCancel": "Are you sure you want to cancel this reservation?",
    "cancellationReason": "Cancellation Reason",
    "cancelled": "Cancelled",
    "completed": "Completed",
    "confirmed": "Confirmed",
    "pending": "Pending",
    "noShow": "No Show",
    "details": "Reservation Details",
    "notes": "Notes",
    "addNotes": "Add Notes",
    "notesUpdated": "Notes updated successfully",
    "rescheduleSession": "Reschedule Session",
    "rescheduleSuccess": "Session rescheduled successfully",
    "with": "with",
    "cancelSuccess": "Reservation cancelled successfully",
    "hostCancelled": "Host cancelled this reservation",
    "madeOn": "Made on",
    "hour": "hour",
    "hours": "hours",
    "min": "min",
    "mins": "mins",
    "chooseTimeSlot": "Choose a time slot",
    "noTimeSlots": "No time slots available for this date",
    "checkAvailability": "Check Availability",
    "availableTimes": "Available Times",
    "session": "Session",
    "sessions": "Sessions",
    "cancelPolicy": "Cancellation Policy",
    "cancelPolicyText": "You can cancel up to 24 hours before your scheduled session for a full refund.",
    "upcomingSession": "Upcoming Session",
    "scheduledFor": "Scheduled for",
    "prepare": "Prepare",
    "prepareForSession": "Prepare for your session"
  },
  "calls": {
    "join": "Join Call",
    "preparing": "Preparing your call...",
    "connecting": "Connecting...",
    "connected": "Connected",
    "disconnected": "Disconnected",
    "reconnecting": "Reconnecting...",
    "cameraOff": "Camera Off",
    "cameraOn": "Camera On",
    "micOff": "Mic Off",
    "micOn": "Mic On",
    "screenShare": "Share Screen",
    "stopScreenShare": "Stop Sharing",
    "leaveCall": "Leave Call",
    "endCall": "End Call",
    "callEnded": "Call ended",
    "confirmEnd": "Are you sure you want to end the call?",
    "waitingForHost": "Waiting for the host to join...",
    "waitingForParticipant": "Waiting for the participant to join...",
    "hostJoined": "Host has joined",
    "participantJoined": "Participant has joined",
    "hostLeft": "Host has left",
    "participantLeft": "Participant has left",
    "connectionError": "Connection error",
    "retrying": "Retrying connection...",
    "refreshPage": "Please refresh the page",
    "callTime": "Call Time",
    "rateSession": "Rate Session",
    "sessionRated": "Session rated successfully",
    "chatToggle": "Toggle Chat",
    "sendMessage": "Send Message",
    "typeMessage": "Type a message...",
    "inCall": "In call with",
    "callDuration": "Call Duration",
    "callStarted": "Call Started",
    "callQuality": "Call Quality",
    "excellent": "Excellent",
    "good": "Good",
    "fair": "Fair",
    "poor": "Poor",
    "testYourConnection": "Test Your Connection",
    "audioTest": "Audio Test",
    "videoTest": "Video Test",
    "settings": "Call Settings",
    "deviceSettings": "Device Settings",
    "selectCamera": "Select Camera",
    "selectMicrophone": "Select Microphone",
    "selectSpeaker": "Select Speaker",
    "noCamera": "No camera detected",
    "noMicrophone": "No microphone detected",
    "noSpeaker": "No speaker detected",
    "connectionTest": "Connection Test",
    "startTest": "Start Test",
    "networkStatus": "Network Status",
    "resolution": "Resolution",
    "frameRate": "Frame Rate",
    "bitrate": "Bitrate"
  },
  "payments": {
    "payments": "Payments",
    "transactions": "Transactions",
    "balance": "Balance",
    "pendingBalance": "Pending Balance",
    "availableBalance": "Available Balance",
    "totalEarnings": "Total Earnings",
    "totalSpent": "Total Spent",
    "addPaymentMethod": "Add Payment Method",
    "paymentMethods": "Payment Methods",
    "defaultPaymentMethod": "Default Payment Method",
    "setAsDefault": "Set as Default",
    "removePaymentMethod": "Remove Payment Method",
    "confirmRemove": "Are you sure you want to remove this payment method?",
    "paymentMethodAdded": "Payment method added successfully",
    "paymentMethodRemoved": "Payment method removed successfully",
    "paymentMethodUpdated": "Payment method updated successfully",
    "cardNumber": "Card Number",
    "expiryDate": "Expiry Date",
    "cvv": "CVV",
    "cardholderName": "Cardholder Name",
    "noPaymentMethods": "No payment methods added yet",
    "noTransactions": "No transactions yet",
    "paymentSuccess": "Payment successful",
    "paymentFailed": "Payment failed",
    "retryPayment": "Retry Payment",
    "amount": "Amount",
    "date": "Date",
    "status": "Status",
    "type": "Type",
    "description": "Description",
    "receipt": "Receipt",
    "invoice": "Invoice",
    "downloadInvoice": "Download Invoice",
    "paymentMethod": "Payment Method",
    "paymentId": "Payment ID",
    "transactionId": "Transaction ID",
    "commission": "Commission",
    "vat": "VAT",
    "total": "Total",
    "pending": "Pending",
    "completed": "Completed",
    "failed": "Failed",
    "refunded": "Refunded",
    "payment": "Payment",
    "payout": "Payout",
    "refund": "Refund",
    "setupStripeAccount": "Setup Stripe Account",
    "completeStripeSetup": "Complete your Stripe account setup to receive payments",
    "stripeAccountSetupComplete": "Stripe account setup complete",
    "pendingBalanceInfo": "Pending balance will be available for withdrawal after 7 days from the completed session.",
    "withdrawFunds": "Withdraw Funds",
    "withdrawalMethod": "Withdrawal Method",
    "bankAccount": "Bank Account",
    "paypal": "PayPal",
    "withdrawalAmount": "Withdrawal Amount",
    "minimumWithdrawal": "Minimum withdrawal amount is 1",
    "withdrawalFee": "Withdrawal Fee",
    "netAmount": "Net Amount",
    "initiateWithdrawal": "Initiate Withdrawal",
    "withdrawalInitiated": "Withdrawal initiated successfully",
    "withdrawalHistory": "Withdrawal History",
    "noWithdrawals": "No withdrawals yet",
    "withdrawalId": "Withdrawal ID",
    "withdrawalDate": "Withdrawal Date",
    "estimatedArrival": "Estimated Arrival"
  },
  "profile": {
    "profile": "Profile",
    "personalInfo": "Personal Information",
    "profilePicture": "Profile Picture",
    "changePicture": "Change Picture",
    "uploadPicture": "Upload Picture",
    "removePhoto": "Remove Photo",
    "firstName": "First Name",
    "lastName": "Last Name",
    "email": "Email",
    "phoneNumber": "Phone Number",
    "bio": "Bio",
    "specialties": "Specialties",
    "languages": "Languages",
    "addLanguage": "Add Language",
    "addSpecialty": "Add Specialty",
    "updateProfile": "Update Profile",
    "updatePassword": "Change Password",
    "currentPassword": "Current Password",
    "newPassword": "New Password",
    "confirmPassword": "Confirm New Password",
    "passwordUpdated": "Password updated successfully",
    "profileUpdated": "Profile updated successfully",
    "becomeHost": "Become a Mentor",
    "hostProfile": "Mentor Profile",
    "hourlyRate": "Hourly Rate",
    "setHourlyRate": "Set your hourly rate",
    "saved": "Saved",
    "notifications": "Notifications",
    "notificationPreferences": "Notification Preferences",
    "emailNotifications": "Email Notifications",
    "pushNotifications": "Push Notifications",
    "smsNotifications": "SMS Notifications",
    "marketing": "Marketing",
    "reservations": "Reservations",
    "payments": "Payments",
    "system": "System",
    "notificationSettingsUpdated": "Notification settings updated successfully",
    "language": "Language",
    "selectLanguage": "Select Language",
    "languageUpdated": "Language updated successfully",
    "timezone": "Timezone",
    "selectTimezone": "Select Timezone",
    "timezoneUpdated": "Timezone updated successfully",
    "deleteAccount": "Delete Account",
    "deleteAccountWarning": "Warning: This action cannot be undone. This will permanently delete your account and remove all your data from our servers.",
    "confirmDeleteAccount": "Are you sure you want to delete your account?",
    "enterPasswordToDelete": "Enter your password to confirm account deletion",
    "accountDeleted": "Account deleted successfully",
    "generalPreferences": "General Preferences",
    "securitySettings": "Security Settings",
    "accountSettings": "Account Settings",
    "education": "Education",
    "workExperience": "Work Experience",
    "addEducation": "Add Education",
    "addWorkExperience": "Add Work Experience",
    "institution": "Institution",
    "degree": "Degree",
    "fieldOfStudy": "Field of Study",
    "startDate": "Start Date",
    "endDate": "End Date",
    "present": "Present",
    "company": "Company",
    "position": "Position",
    "description": "Description",
    "website": "Website",
    "socialProfiles": "Social Profiles",
    "linkedin": "LinkedIn",
    "twitter": "Twitter",
    "github": "GitHub",
    "verificationStatus": "Verification Status",
    "verified": "Verified",
    "unverified": "Unverified",
    "pendingVerification": "Pending Verification",
    "requestVerification": "Request Verification",
    "verificationRequested": "Verification requested successfully"
  },
  "admin": {
    "dashboard": "Admin Dashboard",
    "users": "Users",
    "hosts": "Mentors",
    "reservations": "Reservations",
    "payments": "Payments",
    "reports": "Reports",
    "settings": "Settings",
    "theme": "Theme",
    "content": "Content",
    "achievements": "Achievements",
    "userManagement": "User Management",
    "hostManagement": "Mentor Management",
    "reservationManagement": "Reservation Management",
    "paymentManagement": "Payment Management",
    "systemSettings": "System Settings",
    "createUser": "Create User",
    "userCreated": "User created successfully",
    "userUpdated": "User updated successfully",
    "userDeleted": "User deleted successfully",
    "banUser": "Ban User",
    "unbanUser": "Unban User",
    "verifyUser": "Verify User",
    "userVerified": "User verified successfully",
    "userBanned": "User banned successfully",
    "userUnbanned": "User unbanned successfully",
    "verifyHost": "Verify Mentor",
    "hostVerified": "Mentor verified successfully",
    "featureHost": "Feature Mentor",
    "unfeatureHost": "Unfeature Mentor",
    "hostFeatured": "Mentor featured successfully",
    "hostUnfeatured": "Mentor unfeatured successfully",
    "cancelReservation": "Cancel Reservation",
    "reservationCancelled": "Reservation cancelled successfully",
    "refundPayment": "Refund Payment",
    "paymentRefunded": "Payment refunded successfully",
    "processPayouts": "Process Payouts",
    "payoutsProcessed": "Payouts processed successfully",
    "themeSettings": "Theme Settings",
    "themeUpdated": "Theme updated successfully",
    "contentManagement": "Content Management",
    "createContent": "Create Content",
    "editContent": "Edit Content",
    "Delete Content",
    "contentCreated": "Content created successfully",
    "contentUpdated": "Content updated successfully",
    "contentDeleted": "Content deleted successfully",
    "createAchievement": "Create Achievement",
    "editAchievement": "Edit Achievement",
    "deleteAchievement": "Delete Achievement",
    "achievementCreated": "Achievement created successfully",
    "achievementUpdated": "Achievement updated successfully",
    "achievementDeleted": "Achievement deleted successfully",
    "commissionSettings": "Commission Settings",
    "vatSettings": "VAT Settings",
    "retentionSettings": "Retention Settings",
    "commissionUpdated": "Commission settings updated successfully",
    "vatUpdated": "VAT settings updated successfully",
    "retentionUpdated": "Retention settings updated successfully",
    "systemStats": "System Statistics",
    "totalUsers": "Total Users",
    "totalHosts": "Total Mentors",
    "totalReservations": "Total Reservations",
    "totalRevenue": "Total Revenue",
    "newUsers": "New Users",
    "newReservations": "New Reservations",
    "revenue": "Revenue",
    "period": "Period",
    "daily": "Daily",
    "weekly": "Weekly",
    "monthly": "Monthly",
    "yearly": "Yearly",
    "selectPeriod": "Select Period",
    "filterByDate": "Filter by Date",
    "exportData": "Export Data",
    "importData": "Import Data",
    "dataExported": "Data exported successfully",
    "dataImported": "Data imported successfully",
    "auditLog": "Audit Log",
    "viewLog": "View Log",
    "action": "Action",
    "user": "User",
    "timestamp": "Timestamp",
    "ip": "IP Address",
    "notes": "Notes",
    "noResults": "No results found",
    "searchUsers": "Search Users",
    "searchHosts": "Search Mentors",
    "searchReservations": "Search Reservations",
    "searchPayments": "Search Payments",
    "primaryColor": "Primary Color",
    "secondaryColor": "Secondary Color",
    "accentColor": "Accent Color",
    "backgroundColor": "Background Color",
    "textColor": "Text Color",
    "fontFamily": "Font Family",
    "borderRadius": "Border Radius",
    "fontSize": "Font Size",
    "customCSS": "Custom CSS",
    "logo": "Logo",
    "uploadLogo": "Upload Logo",
    "favicon": "Favicon",
    "uploadFavicon": "Upload Favicon",
    "contentType": "Content Type",
    "title": "Title",
    "body": "Body",
    "image": "Image",
    "uploadImage": "Upload Image",
    "link": "Link",
    "linkText": "Link Text",
    "active": "Active",
    "inactive": "Inactive",
    "startDate": "Start Date",
    "endDate": "End Date",
    "pinned": "Pinned",
    "displayOrder": "Display Order",
    "achievementName": "Achievement Name",
    "achievementDescription": "Achievement Description",
    "achievementIcon": "Achievement Icon",
    "achievementEmoji": "Achievement Emoji",
    "achievementPoints": "Achievement Points",
    "achievementTrigger": "Achievement Trigger",
    "achievementThreshold": "Achievement Threshold",
    "achievementRole": "Achievement Role",
    "commissionRate": "Commission Rate",
    "vatRate": "VAT Rate",
    "retentionDays": "Retention Days",
    "enabled": "Enabled",
    "disabled": "Disabled",
    "role": "Role",
    "roles": "Roles",
    "admin": "Admin",
    "superadmin": "Super Admin",
    "host": "Mentor",
    "user": "User",
    "verified": "Verified",
    "banned": "Banned",
    "created": "Created",
    "updated": "Updated",
    "hostName": "Mentor Name",
    "userName": "User Name",
    "usersReport": "Users Report",
    "hostsReport": "Mentors Report",
    "revenueReport": "Revenue Report",
    "sessionsReport": "Sessions Report",
    "noData": "No data available",
    "colors": "Colors",
    "typography": "Typography",
    "headingFontFamily": "Heading Font Family",
    "totalTransactions": "Total Transactions",
    "totalCommission": "Total Commission",
    "pendingReleases": "Pending Releases",
    "successColor": "Success Color",
    "errorColor": "Error Color",
    "warningColor": "Warning Color",
    "infoColor": "Info Color",
    "surfaceColor": "Surface Color",
    "released": "Released"
  },
  "errors": {
    "somethingWentWrong": "Something went wrong",
    "tryAgain": "Please try again",
    "pageNotFound": "Page Not Found",
    "returnHome": "Return to Home",
    "sessionExpired": "Session Expired",
    "loginAgain": "Please login again",
    "noInternet": "No Internet Connection",
    "checkConnection": "Please check your internet connection",
    "serverError": "Server Error",
    "contactSupport": "Please contact support",
    "unauthorized": "Unauthorized",
    "forbidden": "Forbidden",
    "notFound": "Not Found",
    "badRequest": "Bad Request",
    "conflict": "Conflict",
    "internalError": "Internal Error",
    "unavailable": "Service Unavailable",
    "tryLater": "Please try again later",
    "timeoutError": "Request timed out",
    "validationError": "Validation Error",
    "paymentError": "Payment Error",
    "sessionError": "Session Error",
    "pageNotFoundDescription": "The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.",
    "errorCode": "Error code",
    "goBack": "Go Back",
    "refresh": "Refresh Page",
    "required": "This field is required",
    "invalidFormat": "Invalid format",
    "minLength": "Must be at least 0 characters",
    "maxLength": "Must be at most 128000 characters",
    "minValue": "Must be at least 0",
    "maxValue": "Must be at most 128000",
    "invalidDate": "Invalid date",
    "passwordComplexity": "Password doesn't meet complexity requirements",
    "emailExists": "Email already exists",
    "usernameExists": "Username already exists",
    "accountLocked": "Your account has been locked. Please contact support."
  }
}
EOF
  # Español (versión resumida, en producción debería tener todos los campos)
  cat > public/locales/es/translation.json << 'EOF'
{
  "common": {
    "appName": "Dialoom",
    "loading": "Cargando...",
    "error": "Error",
    "success": "Éxito",
    "cancel": "Cancelar",
    "save": "Guardar",
    "edit": "Editar",
    "delete": "Eliminar",
    "confirm": "Confirmar",
    "back": "Atrás",
    "next": "Siguiente",
    "submit": "Enviar",
    "search": "Buscar",
    "filter": "Filtrar",
    "all": "Todos",
    "yes": "Sí",
    "no": "No",
    "ok": "OK",
    "actions": "Acciones",
    "status": "Estado",
    "details": "Detalles",
    "close": "Cerrar",
    "noData": "No hay datos disponibles",
    "allRightsReserved": "Todos los derechos reservados",
    "day": "Día",
    "week": "Semana",
    "month": "Mes",
    "today": "Hoy"
  },
  "auth": {
    "login": "Iniciar sesión",
    "register": "Registrarse",
    "logout": "Cerrar sesión",
    "email": "Correo electrónico",
    "password": "Contraseña",
    "confirmPassword": "Confirmar contraseña",
    "firstName": "Nombre",
    "lastName": "Apellido",
    "forgotPassword": "¿Olvidó su contraseña?",
    "dontHaveAccount": "¿No tiene una cuenta?",
    "alreadyHaveAccount": "¿Ya tiene una cuenta?",
    "signUp": "Registrarse",
    "signIn": "Iniciar sesión",
    "socialLogin": "O continuar con",
    "loginSuccess": "Inicio de sesión exitoso",
    "registerSuccess": "Registro exitoso",
    "logoutSuccess": "Cierre de sesión exitoso"
  },
  "dashboard": {
    "welcome": "Bienvenido, Frontend3!",
    "noAchievements": "Aún no hay logros"
  },
  "calls": {
    "join": "Unirse a la llamada",
    "preparing": "Preparando la llamada...",
    "connecting": "Conectando...",
    "micOn": "Micrófono encendido",
    "micOff": "Micrófono apagado",
    "cameraOn": "Cámara encendida",
    "cameraOff": "Cámara apagada",
    "screenShare": "Compartir pantalla",
    "stopScreenShare": "Dejar de compartir",
    "endCall": "Finalizar llamada",
    "chatToggle": "Abrir/cerrar chat"
  }
}
EOF
  # Catalán (versión mínima, en producción debería tener todos los campos)
  cat > public/locales/ca/translation.json << 'EOF'
{
  "common": {
    "appName": "Dialoom",
    "loading": "Carregant...",
    "error": "Error",
    "success": "Èxit"
  },
  "auth": {
    "login": "Iniciar sessió",
    "register": "Registrar-se",
    "logout": "Tancar sessió"
  },
  "dashboard": {
    "welcome": "Benvingut, Frontend3!",
    "noAchievements": "Encara no hi ha assoliments"
  }
}
EOF
  log_info "Archivos públicos creados correctamente."
}

# Crear archivos principales de la aplicación
create_main_files() {
  log_step "Creando archivos principales de la aplicación..."
  # Crear src/main.tsx optimizado
  cat > src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { QueryClientProvider } from '@tanstack/react-query'
import App from './App'
import './index.css'
import { AuthProvider } from './shared/contexts/AuthContext'
import { ThemeProvider } from './shared/contexts/ThemeProvider'
import { ToastContainer } from 'react-toastify'
import 'react-toastify/dist/ReactToastify.css'
import { queryClient } from './api/queryClient'
# Inicializar i18n
import './i18n/i18n'
# Importar configuración global
import './config/constants'
# Reportar errores no capturados
const errorHandler = (event: ErrorEvent) => {
  console.error('Unhandled error:', event.error)
  # Aquí podrías implementar logging a un servicio externo como Sentry
}
window.addEventListener('error', errorHandler)
ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <AuthProvider>
          <ThemeProvider>
            <App />
            <ToastContainer
              position="top-right"
              autoClose={5000}
              hideProgressBar={false}
              newestOnTop
              closeOnClick
              rtl={false}
              pauseOnFocusLoss
              draggable
              pauseOnHover
              theme="light"
            />
          </ThemeProvider>
        </AuthProvider>
      </BrowserRouter>
    </QueryClientProvider>
  </React.StrictMode>
)
EOF
  # Crear src/index.css optimizado con la paleta de colores de Dialoom
  cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --color-primary-main: #1A7A8B; /* Azul Dialoom principal */
  --color-primary-light: #2A96AB;
  --color-primary-dark: #0A5A6A;
  --color-secondary-main: #2D3748; /* Gris oscuro para textos */
  --color-secondary-light: #4A5568;
  --color-secondary-dark: #1A202C;
  --color-background: #FFFFFF;
  --color-surface: #F7FAFC;
  --color-error: #E53E3E;
  --color-success: #38A169;
  --color-warning: #ECC94B;
  --color-info: #4299E1;
  --font-family: 'Poppins', sans-serif; /* Poppins como fuente principal según imágenes */
  --heading-font-family: 'Poppins', sans-serif;
  --border-radius: 12px; /* Radios más suaves según imágenes */
  
  /* Sombras personalizadas */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
  
  /* Transiciones */
  --transition-fast: 0.15s ease-in-out;
  --transition-normal: 0.3s ease-in-out;
}

html {
  scroll-behavior: smooth;
}

body {
  margin: 0;
  font-family: var(--font-family);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: var(--color-secondary-main);
  background-color: var(--color-background);
}

h1, h2, h3, h4, h5, h6 {
  font-family: var(--heading-font-family);
  margin-top: 0;
}

button:focus, a:focus, input:focus, textarea:focus, select:focus {
  outline: 2px solid var(--color-primary-light);
  outline-offset: 2px;
}

/* Animaciones */
.fade-in {
  animation: fadeIn var(--transition-normal);
}

.scale-in {
  animation: scaleIn var(--transition-normal);
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes scaleIn {
  from { transform: scale(0.95); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

/* Estilos de utilidad personalizados */
@layer components {
  .btn-primary {
    @apply bg-primary-main text-white font-medium py-2 px-4 rounded-full hover:bg-primary-dark focus:outline-none focus:ring-2 focus:ring-primary-light focus:ring-opacity-50 transition-all shadow-md hover:shadow-lg;
  }
  
  .btn-secondary {
    @apply bg-secondary-main text-white font-medium py-2 px-4 rounded-full hover:bg-secondary-dark focus:outline-none focus:ring-2 focus:ring-secondary-light focus:ring-opacity-50 transition-all shadow-md hover:shadow-lg;
  }
  
  .btn-outline {
    @apply border border-primary-main text-primary-main font-medium py-2 px-4 rounded-full hover:bg-primary-main hover:text-white focus:outline-none focus:ring-2 focus:ring-primary-light focus:ring-opacity-50 transition-all;
  }
  
  .card {
    @apply bg-white rounded-xl shadow-md hover:shadow-lg transition-all duration-300;
  }
  
  .input-field {
    @apply w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-light focus:border-primary-main;
  }
}

/* Accesibilidad - Skip to content link */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: var(--color-primary-main);
  color: white;
  padding: 8px;
  z-index: 9999;
  transition: top 0.3s;
}

.skip-link:focus {
  top: 0;
}
EOF
  # Crear src/App.tsx optimizado con lazy loading
  cat > src/App.tsx << 'EOF'
import { Suspense, lazy } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { CircularProgress, Box, Typography } from '@mui/material'
import { useAuth } from './shared/hooks/useAuth'
import { ProtectedRoute } from './routes/ProtectedRoute'
import { RoleBasedRoute } from './routes/RoleBasedRoute'
import { UserRole } from './shared/types/User'
import MainLayout from './shared/components/layout/MainLayout'
# Importar página de error de manera no lazy para manejo inmediato de errores
import NotFoundPage from './features/error/pages/NotFoundPage'
# Lazy loading de páginas para optimizar el rendimiento inicial
const LoginPage = lazy(() => import('./features/auth/pages/LoginPage'))
const RegisterPage = lazy(() => import('./features/auth/pages/RegisterPage'))
const ForgotPasswordPage = lazy(() => import('./features/auth/pages/ForgotPasswordPage'))
const ResetPasswordPage = lazy(() => import('./features/auth/pages/ResetPasswordPage'))
const DashboardPage = lazy(() => import('./features/dashboard/pages/DashboardPage'))
const HostsListPage = lazy(() => import('./features/hosts/pages/HostsListPage'))
const HostDetailPage = lazy(() => import('./features/hosts/pages/HostDetailPage'))
const ReservationsPage = lazy(() => import('./features/reservations/pages/ReservationsPage'))
const ReservationDetailPage = lazy(() => import('./features/reservations/pages/ReservationDetailPage'))
const CallPage = lazy(() => import('./features/calls/pages/CallPage'))
const PaymentsPage = lazy(() => import('./features/payments/pages/PaymentsPage'))
const ProfilePage = lazy(() => import('./features/profile/pages/ProfilePage'))
const SettingsPage = lazy(() => import('./features/profile/pages/SettingsPage'))
# Admin pages
const AdminDashboardPage = lazy(() => import('./features/admin/pages/AdminDashboardPage'))
const AdminUsersPage = lazy(() => import('./features/admin/pages/users/AdminUsersPage'))
const AdminHostsPage = lazy(() => import('./features/admin/pages/hosts/AdminHostsPage'))
const AdminContentPage = lazy(() => import('./features/admin/pages/content/AdminContentPage'))
const AdminThemePage = lazy(() => import('./features/admin/pages/theme/AdminThemePage'))
const AdminPaymentsPage = lazy(() => import('./features/admin/pages/payments/AdminPaymentsPage'))
const AdminAchievementsPage = lazy(() => import('./features/admin/pages/achievements/AdminAchievementsPage'))
const AdminReportsPage = lazy(() => import('./features/admin/pages/reports/AdminReportsPage'))
# Componente mejorado para fallback de carga
const LoadingFallback = () => (
  <Box
    display="flex"
    flexDirection="column"
    alignItems="center"
    justifyContent="center"
    height="100vh"
    className="fade-in"
  >
    <CircularProgress size={50} thickness={4} sx={{ color: 'var(--color-primary-main)' }} />
    <Typography variant="h6" sx={{ mt: 2 }}>
      Cargando...
    </Typography>
  </Box>
)
function App() {
  const { isAuthenticated, user, loading } = useAuth()
  # Verificar si el usuario es administrador
  const isAdmin = user?.role === UserRole.ADMIN || user?.role === UserRole.SUPERADMIN
  const isHost = user?.role === UserRole.HOST || isAdmin
  if (loading) {
    return <LoadingFallback />
  }
  return (
    <>
      # Enlace para accesibilidad - saltar al contenido principal
      <a href="#main-content" className="skip-link">
        Saltar al contenido principal
      </a>
      <Suspense fallback={<LoadingFallback />}>
        <Routes>
          # Rutas públicas
          <Route path="/login" element={isAuthenticated ? <Navigate to="/dashboard" /> : <LoginPage />} />
          <Route path="/register" element={isAuthenticated ? <Navigate to="/dashboard" /> : <RegisterPage />} />
          <Route path="/forgot-password" element={<ForgotPasswordPage />} />
          <Route path="/reset-password/:token" element={<ResetPasswordPage />} />
          # Rutas protegidas
          <Route element={<ProtectedRoute isAuthenticated={isAuthenticated} />}>
            <Route element={<MainLayout />}>
              <Route path="/" element={<Navigate to="/dashboard" />} />
              <Route path="/dashboard" element={<DashboardPage />} />
              <Route path="/hosts" element={<HostsListPage />} />
              <Route path="/hosts/:id" element={<HostDetailPage />} />
              <Route path="/reservations" element={<ReservationsPage />} />
              <Route path="/reservations/:id" element={<ReservationDetailPage />} />
              <Route path="/payments" element={<PaymentsPage />} />
              <Route path="/profile" element={<ProfilePage />} />
              <Route path="/settings" element={<SettingsPage />} />
              # Rutas específicas de host
              <Route element={<RoleBasedRoute isAllowed={isHost} redirectTo="/dashboard" />}>
                <Route path="/host/dashboard" element={<DashboardPage isHostView />} />
                <Route path="/host/reservations" element={<ReservationsPage isHostView />} />
              </Route>
              # Rutas de Admin
              <Route element={<RoleBasedRoute isAllowed={isAdmin} redirectTo="/dashboard" />}>
                <Route path="/admin" element={<AdminDashboardPage />} />
                <Route path="/admin/users" element={<AdminUsersPage />} />
                <Route path="/admin/hosts" element={<AdminHostsPage />} />
                <Route path="/admin/content" element={<AdminContentPage />} />
                <Route path="/admin/theme" element={<AdminThemePage />} />
                <Route path="/admin/payments" element={<AdminPaymentsPage />} />
                <Route path="/admin/achievements" element={<AdminAchievementsPage />} />
                <Route path="/admin/reports" element={<AdminReportsPage />} />
              </Route>
            </Route>
          </Route>
          # Ruta de videollamada
          <Route path="/call/:reservationId" element={
            <ProtectedRoute isAuthenticated={isAuthenticated}>
              <CallPage />
            </ProtectedRoute>
          } />
          # Ruta 404
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </Suspense>
    </>
  )
}
export default App
EOF
  # Crear configuración de QueryClient
  cat > src/api/queryClient.ts << 'EOF'
import { QueryClient } from '@tanstack/react-query'
import { toast } from 'react-toastify'

# Configurar cliente de React Query con opciones optimizadas
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      retryDelay: attemptIndex => Math.min(1000 * 2 ** attemptIndex, 30000),
      staleTime: 5 * 60 * 1000, # 5 minutos
      gcTime: 10 * 60 * 1000, # 10 minutos
      refetchOnWindowFocus: false,
      onError: (error: unknown) => {  # Explicitly type 'error'
        const errorMessage = error instanceof Error
          ? error.message
          : 'Error desconocido, por favor intenta nuevamente';
        # Solo mostrar toast para errores que no sean 401 (no autorizados)
        # ya que esos son manejados globalmente por el interceptor de axios
        if (!errorMessage.includes('401')) {
          toast.error(errorMessage);
        }
      }
    },
    mutations: {
      retry: 0,
      onError: (error: unknown) => { # Explicitly type 'error'
        const errorMessage = error instanceof Error
          ? error.message
          : 'Error desconocido, por favor intenta nuevamente';
        toast.error(errorMessage);
      }
    }
  },
})
EOF
  # Crear API adapter para mejor manejo de endpoints del backend
  cat > src/api/apiAdapter.ts << 'EOF'
import api from './api';
# Definición de tipos genéricos para adaptadores de API
type ApiResponseType<T> = {
  data: T;
  status: 'success' | 'error';
  message?: string;
};
# Clase adaptadora para endpoints que puede cambiar entre versiones
class ApiEndpointAdapter {
  private baseEndpoint: string;
  private fallbackEndpoint?: string;
  
  constructor(baseEndpoint: string, fallbackEndpoint?: string) {
    this.baseEndpoint = baseEndpoint;
    this.fallbackEndpoint = fallbackEndpoint;
  }
  
  # Método adaptador para peticiones GET
  async get<T>(path: string = '', config?: any): Promise<T> {
    try {
      const response = await api.get<ApiResponseType<T>>(`${this.baseEndpoint}${path}`, config);
      return response.data.data;
    } catch (error: any) {
      # Si hay un 404 y existe un fallback, intentarlo
      if (error.response?.status === 404 && this.fallbackEndpoint) {
        console.warn(`Endpoint ${this.baseEndpoint} not found, trying fallback ${this.fallbackEndpoint}`);
        const fallbackResponse = await api.get<ApiResponseType<T>>(`${this.fallbackEndpoint}${path}`, config);
        return fallbackResponse.data.data;
      }
      throw error;
    }
  }
  
  # Método adaptador para peticiones POST
  async post<T, D = any>(path: string = '', data?: D, config?: any): Promise<T> {
    try {
      const response = await api.post<ApiResponseType<T>>(`${this.baseEndpoint}${path}`, data, config);
      return response.data.data;
    } catch (error: any) {
      if (error.response?.status === 404 && this.fallbackEndpoint) {
        console.warn(`Endpoint ${this.baseEndpoint} not found, trying fallback ${this.fallbackEndpoint}`);
        const fallbackResponse = await api.post<ApiResponseType<T>>(`${this.fallbackEndpoint}${path}`, data, config);
        return fallbackResponse.data.data;
      }
      throw error;
    }
  }
  
  # Método adaptador para peticiones PUT
  async put<T, D = any>(path: string = '', data?: D, config?: any): Promise<T> {
    try {
      const response = await api.put<ApiResponseType<T>>(`${this.baseEndpoint}${path}`, data, config);
      return response.data.data;
    } catch (error: any) {
      if (error.response?.status === 404 && this.fallbackEndpoint) {
        console.warn(`Endpoint ${this.baseEndpoint} not found, trying fallback ${this.fallbackEndpoint}`);
        const fallbackResponse = await api.put<ApiResponseType<T>>(`${this.fallbackEndpoint}${path}`, data, config);
        return fallbackResponse.data.data;
      }
      throw error;
    }
  }
  
  # Método adaptador para peticiones DELETE
  async delete<T>(path: string = '', config?: any): Promise<T> {
    try {
      const response = await api.delete<ApiResponseType<T>>(`${this.baseEndpoint}${path}`, config);
      return response.data.data;
    } catch (error: any) {
      if (error.response?.status === 404 && this.fallbackEndpoint) {
        console.warn(`Endpoint ${this.baseEndpoint} not found, trying fallback ${this.fallbackEndpoint}`);
        const fallbackResponse = await api.delete<ApiResponseType<T>>(`${this.fallbackEndpoint}${path}`, config);
        return fallbackResponse.data.data;
      }
      throw error;
    }
  }
}

# Factory para crear adaptadores de API fácilmente
export const createApiAdapter = (
  baseEndpoint: string,
  fallbackEndpoint?: string
) => new ApiEndpointAdapter(baseEndpoint, fallbackEndpoint);

# Instancias predefinidas para los diferentes servicios
export const authApi = createApiAdapter('/auth', '/v1/auth');
export const hostsApi = createApiAdapter('/hosts', '/v1/hosts');
export const reservationsApi = createApiAdapter('/reservations', '/v1/reservations');
export const callsApi = createApiAdapter('/calls', '/v1/calls');
export const paymentsApi = createApiAdapter('/payments', '/v1/payments');
export const notificationsApi = createApiAdapter('/notifications');

# Exportar un objeto centralizado para facilitar la extensión
const apiAdapters = {
  auth: authApi,
  hosts: hostsApi,
  reservations: reservationsApi,
  calls: callsApi,
  payments: paymentsApi,
  notifications: notificationsApi,
};

export default apiAdapters;
EOF
  # Crear archivo de configuración
  cat > src/config/constants.ts << 'EOF'
# Constantes de la aplicación
# Rutas de API
export const API_ROUTES = {
  AUTH: {
    LOGIN: '/auth/login',
    REGISTER: '/auth/register',
    PROFILE: '/auth/profile',
    FORGOT_PASSWORD: '/auth/forgot-password',
    RESET_PASSWORD: '/auth/reset-password',
    CHANGE_PASSWORD: '/auth/change-password',
    TWO_FACTOR_GENERATE: '/auth/2fa/generate',
    TWO_FACTOR_ENABLE: '/auth/2fa/enable',
    TWO_FACTOR_DISABLE: '/auth/2fa/disable',
  },
  USERS: {
    ME: '/users/me',
    ALL: '/users',
    VERIFY: (id: string) => `/users/${id}/verify`,
    BAN: (id: string) => `/users/${id}/ban`,
    UNBAN: (id: string) => `/users/${id}/unban`,
    ROLE: (id: string) => `/users/${id}/role`,
  },
  HOSTS: {
    ALL: '/hosts',
    FEATURED: '/hosts?featured=true',
    DETAIL: (id: string) => `/hosts/${id}`,
    VERIFY: (id: string) => `/admin/hosts/${id}/verify`,
    FEATURE: (id: string) => `/admin/hosts/${id}/featured`,
  },
  RESERVATIONS: {
    ALL: '/reservations',
    ME: '/reservations/me',
    UPCOMING: '/reservations/upcoming',
    DETAIL: (id: string) => `/reservations/${id}`,
    CANCEL: (id: string) => `/reservations/${id}/cancel`,
    RESCHEDULE: (id: string) => `/reservations/${id}/reschedule`,
    STATUS: (id: string) => `/reservations/${id}/status`,
    AVAILABILITY: '/reservations/availability',
    HOST_AVAILABILITY: (id: string) => `/reservations/availability/${id}`,
  },
  CALLS: {
    TOKEN: '/calls/token',
  },
  PAYMENTS: {
    ALL: '/payments',
    ME: '/payments/me',
    CREATE_INTENT: '/payments/create-intent',
    STATS: '/payments/stats',
    REFUND: (id: string) => `/payments/refund/${id}`,
    PROCESS_RELEASES: '/payments/process-releases',
    CREATE_CONNECT: '/payments/create-connect-account',
  },
  ADMIN: {
    THEME: '/admin/theme',
    CONTENT: '/admin/content',
    CONTENT_ACTIVE: '/admin/content/active',
    CONTENT_DETAIL: (id: string) => `/admin/content/${id}`,
  },
};
# Constantes de localización
export const SUPPORTED_LANGUAGES = [
  { code: 'en', name: 'English' },
  { code: 'es', name: 'Español' },
  { code: 'ca', name: 'Català' },
  { code: 'de', name: 'Deutsch' },
  { code: 'fr', name: 'Français' },
  { code: 'nl', name: 'Nederlands' },
  { code: 'it', name: 'Italiano' },
];
# Constantes para manejo de errores
export const ERROR_MESSAGES = {
  NETWORK_ERROR: 'Error de conexión. Por favor, verifica tu conexión a internet.',
  SERVER_ERROR: 'Error del servidor. Por favor, inténtalo de nuevo más tarde.',
  AUTH_ERROR: 'Error de autenticación. Por favor, inicia sesión nuevamente.',
  VALIDATION_ERROR: 'Error de validación. Por favor, revisa los datos ingresados.',
  UNAUTHORIZED: 'No autorizado. No tienes permiso para realizar esta acción.',
  FORBIDDEN: 'Acceso denegado. No tienes permiso para acceder a este recurso.',
  NOT_FOUND: 'Recurso no encontrado.',
  CONFLICT: 'Conflicto. El recurso ya existe o ha sido modificado.',
  TIMEOUT: 'La solicitud ha excedido el tiempo límite. Por favor, inténtalo de nuevo.',
};
# Paginación por defecto
export const DEFAULT_PAGE_SIZE = 10;
export const PAGE_SIZE_OPTIONS = [5, 10, 25, 50];
# Duración de sesión
export const SESSION_DURATION = 86400; # 24 horas en segundos
# Constantes para videollamadas
export const CALL_QUALITY_PROFILES = {
  HIGH: {
    videoQuality: '720p_2', # 720p a 30fps
    audioQuality: 'music_standard',
  },
  MEDIUM: {
    videoQuality: '480p_2', # 4
80p a 30fps
    audioQuality: 'music_standard',
  },
  LOW: {
    videoQuality: '360p_1', # 360p a 15fps
    audioQuality: 'speech_standard',
  },
};
EOF
  # Crear archivo i18n configurado
  cat > src/i18n/i18n.ts << 'EOF'
import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import Backend from 'i18next-http-backend'
import { SUPPORTED_LANGUAGES } from '../config/constants'

# Configurar i18next con detección automática y carga asíncrona
i18n
  .use(Backend)
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    fallbackLng: 'es',
    supportedLngs: SUPPORTED_LANGUAGES.map(lang => lang.code),
    debug: import.meta.env.VITE_ENVIRONMENT === 'development',
    interpolation: {
      escapeValue: false, # React ya escapa por defecto
    },
    backend: {
      loadPath: '/locales/{{lng}}/translation.json',
    },
    detection: {
      order: ['localStorage', 'cookie', 'navigator'],
      caches: ['localStorage', 'cookie'],
      lookupLocalStorage: 'i18nextLng',
      lookupCookie: 'i18next',
    },
    load: 'languageOnly', # Cargar solo el idioma base (ej: 'es' en lugar de 'es-ES')
    ns: ['translation'],
    defaultNS: 'translation',
    react: {
      useSuspense: true,
      transSupportBasicHtmlNodes: true,
    },
  })

# Exportar una función para cambiar idioma que persiste en localStorage
export const changeLanguage = (lng: string) => {
  i18n.changeLanguage(lng)
  localStorage.setItem('i18nextLng', lng)
}

export default i18n
EOF
  log_info "Archivos principales creados correctamente."
}

# Crear contextos para la aplicación
create_contexts() {
  log_step "Creando contextos para la aplicación..."
  # Crear ProtectedRoute
  mkdir -p src/routes
  cat > src/routes/ProtectedRoute.tsx << 'EOF'
import { Navigate, Outlet, useLocation } from 'react-router-dom'

interface ProtectedRouteProps {
  isAuthenticated: boolean
  children?: React.ReactNode
  redirectPath?: string
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  isAuthenticated,
  children,
  redirectPath = '/login',
}) => {
  const location = useLocation()
  if (!isAuthenticated) {
    # Guardar la ubicación actual para redirigir después del login
    return <Navigate to={redirectPath} state={{ from: location }} replace />
  }
  return children ? <>{children}</> : <Outlet />
}
EOF
  # Crear RoleBasedRoute
  cat > src/routes/RoleBasedRoute.tsx << 'EOF'
import { Navigate, Outlet } from 'react-router-dom'

interface RoleBasedRouteProps {
  isAllowed: boolean
  redirectTo?: string
  children?: React.ReactNode
}

export const RoleBasedRoute: React.FC<RoleBasedRouteProps> = ({
  isAllowed,
  redirectTo = '/dashboard',
  children,
}) => {
  if (!isAllowed) {
    return <Navigate to={redirectTo} replace />
  }
  return children ? <>{children}</> : <Outlet />
}
EOF
  # Crear AuthContext optimizado
  mkdir -p src/shared/contexts
  cat > src/shared/contexts/AuthContext.tsx << 'EOF'
import React, { createContext, useState, useEffect, useCallback } from 'react'
import { jwtDecode } from 'jwt-decode'
import { toast } from 'react-toastify'
import api from '@/api/api'
import { User } from '@/shared/types/User'
import { API_ROUTES, SESSION_DURATION } from '@/config/constants'

interface AuthContextType {
  isAuthenticated: boolean
  user: User | null
  loading: boolean
  login: (email: string, password: string, twoFactorCode?: string) => Promise<any>
  register: (userData: any) => Promise<any>
  logout: () => void
  updateUser: (userData: Partial<User>) => void
  checkAuth: () => Promise<boolean>
}
interface JwtPayload {
  sub: string
  exp: number
  iat: number
}
export const AuthContext = createContext<AuthContextType>({
  isAuthenticated: false,
  user: null,
  loading: true,
  login: async () => ({}),
  register: async () => ({}),
  logout: () => {},
  updateUser: () => {},
  checkAuth: async () => false,
})
export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false)
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState<boolean>(true)
  # Función para verificar la autenticación actual
  const checkAuth = useCallback(async () => {
    const token = localStorage.getItem('token')
    if (!token) {
      setLoading(false)
      return false
    }
    try {
      # Verificar si el token ha expirado
      const decoded: JwtPayload = jwtDecode(token)
      const currentTime = Date.now() / 1000
      if (decoded.exp < currentTime) {
        # Token ha expirado
        handleLogout()
        return false
      }
      # Configurar el header de autorización
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`
      # Obtener el perfil del usuario
      const { data } = await api.get(API_ROUTES.AUTH.PROFILE)
      setUser(data)
      setIsAuthenticated(true)
      setLoading(false)
      return true
    } catch (error) {
      console.error('Error verificando autenticación:', error)
      handleLogout()
      setLoading(false)
      return false
    }
  }, [])
  # Verificar autenticación al montar el componente
  useEffect(() => {
    checkAuth()
  }, [checkAuth])
  # Configurar comprobación periódica de expiración de token
  useEffect(() => {
    if (!isAuthenticated) return
    const tokenCheckInterval = setInterval(() => {
      const token = localStorage.getItem('token')
      if (!token) {
        clearInterval(tokenCheckInterval)
        return
      }
      try {
        const decoded: JwtPayload = jwtDecode(token)
        const currentTime = Date.now() / 1000
        const expiresIn = decoded.exp - currentTime
        # Si quedan menos de 5 minutos, mostrar advertencia
        if (expiresIn < 300) {
          toast.warning('Tu sesión está por expirar. Por favor, vuelve a iniciar sesión pronto.')
        }
        # Si el token ha expirado, cerrar sesión
        if (expiresIn <= 0) {
          clearInterval(tokenCheckInterval)
          handleLogout()
          toast.error('Tu sesión ha expirado. Por favor, inicia sesión de nuevo.')
        }
      } catch (error) {
        clearInterval(tokenCheckInterval)
        handleLogout()
      }
    }, 60000) # Comprobar cada minuto
    return () => clearInterval(tokenCheckInterval)
  }, [isAuthenticated])
  const handleLogin = async (email: string, password: string, twoFactorCode?: string) => {
    try {
      const { data } = await api.post(API_ROUTES.AUTH.LOGIN, { email, password, twoFactorCode })
      # Verificar si se requiere 2FA
      if (data.requiresTwoFactor) {
        return { requiresTwoFactor: true }
      }
      const { accessToken, user } = data
      localStorage.setItem('token', accessToken)
      api.defaults.headers.common['Authorization'] = `Bearer ${accessToken}`
      setUser(user)
      setIsAuthenticated(true)
      toast.success('Login exitoso')
      return { success: true, user }
    } catch (error: any) {
      const message = error.response?.data?.message || 'Error al iniciar sesión. Inténtelo de nuevo.'
      toast.error(message)
      throw error
    }
  }
  const handleRegister = async (userData: any) => {
    try {
      const { data } = await api.post(API_ROUTES.AUTH.REGISTER, userData)
      const { accessToken, user } = data
      localStorage.setItem('token', accessToken)
      api.defaults.headers.common['Authorization'] = `Bearer ${accessToken}`
      setUser(user)
      setIsAuthenticated(true)
      toast.success('Registro exitoso')
      return { success: true, user }
    } catch (error: any) {
      const message = error.response?.data?.message || 'Error al registrarse. Inténtelo de nuevo.'
      toast.error(message)
      throw error
    }
  }
  const handleLogout = () => {
    localStorage.removeItem('token')
    delete api.defaults.headers.common['Authorization']
    setUser(null)
    setIsAuthenticated(false)
  }
  const updateUser = (userData: Partial<User>) => {
    setUser(prev => prev ? { ...prev, ...userData } : null)
  }
  return (
    <AuthContext.Provider
      value={{
        isAuthenticated,
        user,
        loading,
        login: handleLogin,
        register: handleRegister,
        logout: handleLogout,
        updateUser,
        checkAuth,
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}
EOF
  # Crear ThemeProvider optimizado con los colores de Dialoom
  cat > src/shared/contexts/ThemeProvider.tsx << 'EOF'
import React, { createContext, useState, useEffect } from 'react'
import { ThemeProvider as MUIThemeProvider, createTheme, Theme } from '@mui/material/styles'
import { useQuery } from '@tanstack/react-query'
import api from '@/api/api'
import { ThemeSettings } from '@/shared/types/ThemeSettings'
import { API_ROUTES } from '@/config/constants'

interface ThemeContextType {
  themeSettings: ThemeSettings | null
  theme: Theme
  updateTheme: (themeData: Partial<ThemeSettings>) => Promise<void>
  loading: boolean
  error: any
}
export const ThemeContext = createContext<ThemeContextType>({
  themeSettings: null,
  theme: createTheme(),
  updateTheme: async () => {},
  loading: false,
  error: null,
})
export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [themeSettings, setThemeSettings] = useState<ThemeSettings | null>(null)
  # Obtener la configuración del tema desde la API
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['themeSettings'],
    queryFn: async () => {
      try {
        const response = await api.get(API_ROUTES.ADMIN.THEME)
        return response.data
      } catch (error) {
        console.error('Error al obtener configuración del tema:', error)
        return null
      }
    },
    refetchOnWindowFocus: false,
    staleTime: 24 * 60 * 60 * 1000, # 24 horas (el tema no cambia frecuentemente)
  })
  useEffect(() => {
    if (data) {
      setThemeSettings(data)
    }
  }, [data])
  # Crear el tema de MUI basado en la configuración
  const theme = createTheme({
    palette: {
      primary: {
        main: themeSettings?.primaryColor || '#1A7A8B', # Azul Dialoom
        light: themeSettings?.primaryColor ? lightenColor(themeSettings.primaryColor, 20) : '#2A96AB',
        dark: themeSettings?.primaryColor ? darkenColor(themeSettings.primaryColor, 20) : '#0A5A6A',
      },
      secondary: {
        main: themeSettings?.secondaryColor || '#2D3748', # Gris oscuro para textos
        light: themeSettings?.secondaryColor ? lightenColor(themeSettings.secondaryColor, 20) : '#4A5568',
        dark: themeSettings?.secondaryColor ? darkenColor(themeSettings.secondaryColor, 20) : '#1A202C',
      },
      error: {
        main: themeSettings?.errorColor || '#E53E3E',
      },
      success: {
        main: themeSettings?.successColor || '#38A169',
      },
      warning: {
        main: themeSettings?.warningColor || '#ECC94B',
      },
      info: {
        main: themeSettings?.infoColor || '#4299E1',
      },
      background: {
        default: themeSettings?.backgroundColor || '#FFFFFF',
        paper: themeSettings?.surfaceColor || '#F7FAFC',
      },
    },
    typography: {
      fontFamily: themeSettings?.fontFamily || "'Poppins', sans-serif",
      h1: {
        fontFamily: themeSettings?.headingFontFamily || "'Poppins', sans-serif",
        fontWeight: 600,
      },
      h2: {
        fontFamily: themeSettings?.headingFontFamily || "'Poppins', sans-serif",
        fontWeight: 600,
      },
      h3: {
        fontFamily: themeSettings?.headingFontFamily || "'Poppins', sans-serif",
        fontWeight: 500,
      },
      h4: {
        fontFamily: themeSettings?.headingFontFamily || "'Poppins', sans-serif",
        fontWeight: 500,
      },
      h5: {
        fontFamily: themeSettings?.headingFontFamily || "'Poppins', sans-serif",
        fontWeight: 500,
      },
      h6: {
        fontFamily: themeSettings?.headingFontFamily || "'Poppins', sans-serif",
        fontWeight: 500,
      },
      button: {
        textTransform: 'none',
        fontWeight: 500,
      },
    },
    shape: {
      borderRadius: parseInt(themeSettings?.borderRadius || '12'), # Bordes más redondeados según imágenes
    },
    breakpoints: {
      values: {
        xs: 0,
        sm: 600,
        md: 960,
        lg: 1280,
        xl: 1920,
      },
    },
    components: {
      MuiButton: {
        styleOverrides: {
          root: {
            borderRadius: 50, # Botones circulares como en las imágenes
            textTransform: 'none',
            padding: '8px 20px',
            fontWeight: 500,
            boxShadow: '0 2px 5px rgba(0, 0, 0, 0.1)',
            transition: 'all 0.3s ease',
            '&:hover': {
              boxShadow: '0 4px 10px rgba(0, 0, 0, 0.15)',
              transform: 'translateY(-2px)',
            },
          },
        },
      },
      MuiCard: {
        styleOverrides: {
          root: {
            borderRadius: parseInt(themeSettings?.borderRadius || '12'),
            boxShadow: '0 4px 10px rgba(0, 0, 0, 0.05)',
            '&:hover': {
              boxShadow: '0 8px 20px rgba(0, 0, 0, 0.1)',
            },
            transition: 'box-shadow 0.3s ease, transform 0.3s ease',
          },
        },
      },
      MuiTextField: {
        styleOverrides: {
          root: {
            '& .MuiOutlinedInput-root': {
              borderRadius: parseInt(themeSettings?.borderRadius || '12') / 2,
              '&:hover .MuiOutlinedInput-notchedOutline': {
                borderColor: themeSettings?.primaryColor || '#1A7A8B',
              },
            },
          },
        },
      },
      MuiPaper: {
        styleOverrides: {
          rounded: {
            borderRadius: parseInt(themeSettings?.borderRadius || '12'),
          },
          elevation1: {
            boxShadow: '0 2px 10px rgba(0, 0, 0, 0.05)',
          },
        },
      },
      MuiChip: {
        styleOverrides: {
          root: {
            borderRadius: 50,
            fontWeight: 500,
          },
        },
      },
      MuiListItem: {
        styleOverrides: {
          root: {
            borderRadius: parseInt(themeSettings?.borderRadius || '12') / 2,
          },
        },
      },
    },
  })
  # Actualizar el tema
  const updateTheme = async (themeData: Partial<ThemeSettings>) => {
    try {
      await api.put(API_ROUTES.ADMIN.THEME, themeData)
      await refetch() # Recargar la configuración del tema
    } catch (error) {
      console.error('Error al actualizar el tema:', error)
      throw error
    }
  }
  # Aplicar CSS personalizado si existe
  useEffect(() => {
    if (themeSettings?.customCss) {
      let styleEl = document.getElementById('custom-theme-css')
      if (!styleEl) {
        styleEl = document.createElement('style')
        styleEl.id = 'custom-theme-css'
        document.head.appendChild(styleEl)
      }
      styleEl.innerHTML = themeSettings.customCss
    }
    # Actualizar variables CSS
    if (themeSettings) {
      document.documentElement.style.setProperty('--color-primary-main', themeSettings.primaryColor || '#1A7A8B')
      document.documentElement.style.setProperty('--color-primary-light', lightenColor(themeSettings.primaryColor || '#1A7A8B', 20))
      document.documentElement.style.setProperty('--color-primary-dark', darkenColor(themeSettings.primaryColor || '#1A7A8B', 20))
      document.documentElement.style.setProperty('--color-secondary-main', themeSettings.secondaryColor || '#2D3748')
      document.documentElement.style.setProperty('--color-secondary-light', lightenColor(themeSettings.secondaryColor || '#2D3748', 20))
      document.documentElement.style.setProperty('--color-secondary-dark', darkenColor(themeSettings.secondaryColor || '#2D3748', 20))
      document.documentElement.style.setProperty('--color-background', themeSettings.backgroundColor || '#FFFFFF')
      document.documentElement.style.setProperty('--color-surface', themeSettings.surfaceColor || '#F7FAFC')
      document.documentElement.style.setProperty('--color-error', themeSettings.errorColor || '#E53E3E')
      document.documentElement.style.setProperty('--color-success', themeSettings.successColor || '#38A169')
      document.documentElement.style.setProperty('--color-warning', themeSettings.warningColor || '#ECC94B')
      document.documentElement.style.setProperty('--color-info', themeSettings.infoColor || '#4299E1')
      document.documentElement.style.setProperty('--font-family', themeSettings.fontFamily || "'Poppins', sans-serif")
      document.documentElement.style.setProperty('--heading-font-family', themeSettings.headingFontFamily || "'Poppins', sans-serif")
      document.documentElement.style.setProperty('--border-radius', themeSettings.borderRadius || '12px')
    }
  }, [themeSettings])
  return (
    <ThemeContext.Provider
      value={{
        themeSettings,
        theme,
        updateTheme,
        loading: isLoading,
        error,
      }}
    >
      <MUIThemeProvider theme={theme}>
        {children}
      </MUIThemeProvider>
    </ThemeContext.Provider>
  )
}
# Utilidades para aclarar y oscurecer colores
function lightenColor(color: string, percent: number): string {
  # Implementación simple para aclarar un color
  const num = parseInt(color.replace('#', ''), 16);
  const amt = Math.round(2.55 * percent);
  const R = (num >> 16) + amt;
  const G = (num >> 8 & 0x00FF) + amt;
  const B = (num & 0x0000FF) + amt;
  return '#' + (
    0x1000000 +
    (R < 255 ? (R < 0 ? 0 : R) : 255) * 0x10000 +
    (G < 255 ? (G < 0 ? 0 : G) : 255) * 0x100 +
    (B < 255 ? (B < 0 ? 0 : B) : 255)
  ).toString(16).slice(1);
}
function darkenColor(color: string, percent: number): string {
  # Implementación simple para oscurecer un color
  return lightenColor(color, -percent);
}
EOF
  log_info "Contextos creados correctamente."
}

# Crear configuración de API
create_api_service() {
  log_step "Creando servicios de API..."
  # Configuración base de API optimizada
  cat > src/api/api.ts << 'EOF'
import axios from 'axios'
import { toast } from 'react-toastify'
import { ERROR_MESSAGES } from '@/config/constants'

# Crear instancia de axios con configuración optimizada
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'https://core.dialoom.com/api',
  timeout: 15000, # 15 segundos de timeout
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  },
})

# Interceptor de peticiones
api.interceptors.request.use(
  (config) => {
    # Agregar token de autenticación si existe
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    # Agregar timestamp para evitar caché en peticiones GET
    if (config.method?.toLowerCase() === 'get') {
      config.params = {
        ...config.params,
        _t: new Date().getTime(),
      }
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

# Interceptor de respuestas
api.interceptors.response.use(
  (response) => {
    return response
  },
  (error) => {
    # Manejar errores de red
    if (!error.response) {
      toast.error(ERROR_MESSAGES.NETWORK_ERROR)
      return Promise.reject(new Error(ERROR_MESSAGES.NETWORK_ERROR))
    }
    const { status, data } = error.response
    # Manejar diferentes códigos de estado
    switch (status) {
      case 401: # No autorizado
        if (localStorage.getItem('token')) {
          localStorage.removeItem('token')
          # No mostrar toast si estamos en la página de login
          if (!window.location.pathname.includes('/login')) {
            toast.error(ERROR_MESSAGES.AUTH_ERROR)
            # Redirigir a login después de un breve retraso
            setTimeout(() => {
              window.location.href = '/login'
            }, 1500)
          }
        }
        break
      case 403: # Prohibido
        toast.error(ERROR_MESSAGES.FORBIDDEN)
        break
      case 404: # No encontrado
        toast.error(data?.message || ERROR_MESSAGES.NOT_FOUND)
        break
      case 422: # Error de validación
        if (data.errors) {
          # Mostrar solo el primer error de validación para no sobrecargar
          const firstError = Object.values(data.errors)[0]
          toast.error(Array.isArray(firstError) ? firstError[0] : firstError)
        } else {
          toast.error(data?.message || ERROR_MESSAGES.VALIDATION_ERROR)
        }
        break
      case 429: # Demasiadas peticiones
        toast.error('Demasiadas peticiones. Por favor, inténtalo más tarde.')
        break
      case 500: # Error del servidor
      case 502: # Bad Gateway
      case 503: # Servicio no disponible
      case 504: # Gateway Timeout
        toast.error(ERROR_MESSAGES.SERVER_ERROR)
        break
      default:
        # Para cualquier otro error
        toast.error(data?.message || 'Ha ocurrido un error. Por favor, inténtalo de nuevo.')
    }
    return Promise.reject(error)
  }
)
export default api
EOF
  # Crear hook personalizado para mutaciones API
  mkdir -p src/shared/hooks
  cat > src/shared/hooks/useApiMutation.ts << 'EOF'
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';

# Hook personalizado para mutaciones de API con mensajes automáticos
export function useApiMutation<TData = unknown, TError = unknown, TVariables = void, TContext = unknown>(
  mutationFn: (variables: TVariables) => Promise<TData>,
  options: {
    mutationKey: string[];
    onSuccessMessage?: string;
    onErrorMessage?: string;
    invalidateQueries?: string[];
    onSuccess?: (data: TData, variables: TVariables, context: TContext | undefined) => void | Promise<unknown>;
    onError?: (error: TError, variables: TVariables, context: TContext | undefined) => void | Promise<unknown>;
  }
) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn,
    onSuccess: (data, variables, context) => {
      # Mostrar mensaje de éxito si se proporciona
      if (options.onSuccessMessage) {
        toast.success(t(options.onSuccessMessage));
      }
      
      # Invalidar consultas si se especifican
      if (options.invalidateQueries?.length) {
        options.invalidateQueries.forEach(queryKey => {
          queryClient.invalidateQueries({ queryKey: [queryKey] });
        });
      }
      
      # Llamar al callback onSuccess personalizado si existe
      if (options.onSuccess) {
        return options.onSuccess(data, variables, context); // context is already optional
      }
    },
    onError: (error: any, variables, context) => {
      # Extraer mensaje de error
      const errorMessage = error?.response?.data?.message || error?.message || options.onErrorMessage || t('errors.somethingWentWrong');
      
      # Mostrar mensaje de error
      toast.error(errorMessage);
      
      # Llamar al callback onError personalizado si existe
      if (options.onError) {
        return options.onError(error, variables, context); // context is already optional
      }
    },
  });
}
EOF
  # Crear servicios de API específicos por feature
  mkdir -p src/features/auth/services
  cat > src/features/auth/services/authService.ts << 'EOF'
import api from '@/api/api'
import { API_ROUTES } from '@/config/constants'
import { User } from '@/shared/types/User'

interface LoginResponse {
  accessToken: string
  user: User
  requiresTwoFactor?: boolean
}

interface RegisterResponse {
  accessToken: string
  user: User
}

export const loginUser = async (email: string, password: string, twoFactorCode?: string): Promise<LoginResponse> => {
  const response = await api.post(API_ROUTES.AUTH.LOGIN, { email, password, twoFactorCode })
  return response.data
}

export const registerUser = async (userData: any): Promise<RegisterResponse> => {
  const response = await api.post(API_ROUTES.AUTH.REGISTER, userData)
  return response.data
}

export const getUserProfile = async (): Promise<User> => {
  const response = await api.get(API_ROUTES.AUTH.PROFILE)
  return response.data
}

export const updateUserProfile = async (userData: Partial<User>): Promise<User> => {
  const response = await api.put(API_ROUTES.USERS.ME, userData)
  return response.data
}

export const changePassword = async (currentPassword: string, newPassword: string): Promise<any> => {
  const response = await api.put(API_ROUTES.AUTH.CHANGE_PASSWORD, { currentPassword, newPassword })
  return response.data
}

export const forgotPassword = async (email: string): Promise<any> => {
  const response = await api.post(API_ROUTES.AUTH.FORGOT_PASSWORD, { email })
  return response.data
}

export const resetPassword = async (token: string, password: string, passwordConfirmation: string): Promise<any> => {
  const response = await api.post(API_ROUTES.AUTH.RESET_PASSWORD, {
    token,
    password,
    password_confirmation: passwordConfirmation
  })
  return response.data
}

export const setupTwoFactor = async (): Promise<any> => {
  const response = await api.post(API_ROUTES.AUTH.TWO_FACTOR_GENERATE)
  return response.data
}

export const enableTwoFactor = async (secret: string, code: string): Promise<any> => {
  const response = await api.post(API_ROUTES.AUTH.TWO_FACTOR_ENABLE, { secret, code })
  return response.data
}

export const disableTwoFactor = async (): Promise<any> => {
  const response = await api.put(API_ROUTES.AUTH.TWO_FACTOR_DISABLE)
  return response.data
}
EOF
  mkdir -p src/features/hosts/services
  cat > src/features/hosts/services/hostService.ts << 'EOF'
import api from '@/api/api'
import { API_ROUTES } from '@/config/constants'
import { Host } from '@/shared/types/Host'

interface HostsQueryParams {
  page?: number
  limit?: number
  search?: string
  specialty?: string
  language?: string
  minRating?: number
  maxPrice?: number
  featured?: boolean
  sortBy?: 'rating' | 'price' | 'createdAt'
  sortOrder?: 'asc' | 'desc'
}
interface HostsResponse {
  hosts: Host[]
  total: number
  page: number
  limit: number
  totalPages: number
}
interface AvailabilityData {
  hostId: string
  availabilitySlots: {
    day: number # 0-6 (domingo-sábado)
    startTime: string # formato 'HH:MM'
    endTime: string # formato 'HH:MM'
  }[]
}
export const getAllHosts = async (params?: HostsQueryParams): Promise<HostsResponse> => {
  const response = await api.get(API_ROUTES.HOSTS.ALL, { params })
  return response.data
}
export const getFeaturedHosts = async (): Promise<Host[]> => {
  const response = await api.get(API_ROUTES.HOSTS.FEATURED)
  return response.data.hosts
}
export const getHostById = async (id: string): Promise<Host> => {
  const response = await api.get(API_ROUTES.HOSTS.DETAIL(id))
  return response.data
}
export const createHostProfile = async (hostData: Partial<Host>): Promise<Host> => {
  const response = await api.post(API_ROUTES.HOSTS.ALL, hostData)
  return response.data
}
export const updateHostProfile = async (id: string, hostData: Partial<Host>): Promise<Host> => {
  const response = await api.put(API_ROUTES.HOSTS.DETAIL(id), hostData)
  return response.data
}
export const setHostAvailability = async (availabilityData: AvailabilityData): Promise<any> => {
  const response = await api.post(API_ROUTES.RESERVATIONS.AVAILABILITY, availabilityData)
  return response.data
}
export const getHostAvailability = async (hostId: string, startDate: string, endDate: string): Promise<any> => {
  const response = await api.get(API_ROUTES.RESERVATIONS.HOST_AVAILABILITY(hostId), {
    params: { startDate, endDate }
  })
  return response.data
}
# Operaciones Admin
export const verifyHost = async (id: string): Promise<any> => {
  const response = await api.put(API_ROUTES.HOSTS.VERIFY(id))
  return response.data
}
export const featureHost = async (id: string, featured: boolean): Promise<any> => {
  const response = await api.put(API_ROUTES.HOSTS.FEATURE(id), { featured })
  return response.data
}
EOF
  # Creamos la página NotFoundPage para que el App.tsx funcione correctamente
  mkdir -p src/features/error/pages
  cat > src/features/error/pages/NotFoundPage.tsx << 'EOF'
import React from 'react'
import { Link as RouterLink } from 'react-router-dom'
import { Box, Button, Container, Typography } from '@mui/material'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'

const NotFoundPage: React.FC = () => {
  const { t } = useTranslation()
  return
(
    <Container maxWidth="md">
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          textAlign: 'center',
          py: 8,
        }}
      >
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <Typography
            variant="h1"
            component="h1"
            gutterBottom
            sx={{
              fontSize: { xs: '6rem', md: '8rem' },
              fontWeight: 'bold',
              color: 'primary.main',
            }}
          >
            404
          </Typography>
        </motion.div>
        
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.2 }}
        >
          <Typography
            variant="h4"
            component="h2"
            gutterBottom
            sx={{ mb: 3 }}
          >
            {t('errors.pageNotFound')}
          </Typography>
        </motion.div>
        
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.4 }}
        >
          <Typography
            variant="body1"
            color="text.secondary"
            paragraph
            sx={{ maxWidth: 600, mb: 4 }}
          >
            {t('errors.pageNotFoundDescription')}
          </Typography>
        </motion.div>
        
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.6 }}
        >
          <Box sx={{ display: 'flex', gap: 2 }}>
            <Button
              component={RouterLink}
              to="/"
              variant="contained"
              color="primary"
              size="large"
              sx={{ borderRadius: 50, px: 4 }}
            >
              {t('errors.returnHome')}
            </Button>
            <Button
              component="button"
              onClick={() => window.history.back()}
              variant="outlined"
              color="primary"
              size="large"
              sx={{ borderRadius: 50, px: 4 }}
            >
              {t('errors.goBack')}
            </Button>
          </Box>
        </motion.div>
      </Box>
    </Container>
  )
}
export default NotFoundPage
EOF
  # Crear componente MainLayout básico
  mkdir -p src/shared/components/layout
  cat > src/shared/components/layout/MainLayout.tsx << 'EOF'
import React, { useState } from 'react'
import { Outlet } from 'react-router-dom'
import { Box, CssBaseline } from '@mui/material'
import Navbar from './Navbar'
import Sidebar from './Sidebar'
import Footer from './Footer'

const MainLayout: React.FC = () => {
  const [mobileOpen, setMobileOpen] = useState(false)
  const drawerWidth = 260
  
  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen)
  }
  
  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      <CssBaseline />
      <Navbar drawerWidth={drawerWidth} onDrawerToggle={handleDrawerToggle} />
      <Sidebar
        drawerWidth={drawerWidth}
        mobileOpen={mobileOpen}
        onDrawerToggle={handleDrawerToggle}
      />
      <Box
        component="main"
        id="main-content" # ID para accesibilidad - skip link
        sx={{
          flexGrow: 1,
          p: { xs: 2, sm: 3 },
          width: { sm: "calc(100% - " + drawerWidth + "px)" },
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        <Box sx={{ height: 64 }} /> # Espacio para el Navbar
        <Box sx={{ flexGrow: 1 }}>
          <Outlet /> # Renderiza la ruta actual
        </Box>
        <Footer />
      </Box>
    </Box>
  )
}
export default MainLayout
EOF
  # Crear placeholder para los componentes Navbar mejorado con animación
  cat > src/shared/components/layout/Navbar.tsx << 'EOF'
import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  AppBar,
  Avatar,
  IconButton,
  Menu,
  MenuItem,
  Toolbar,
  Typography,
  Button,
  useTheme,
  useMediaQuery,
  Badge,
  Tooltip,
  Box,
  Slide,
} from '@mui/material'
import MenuIcon from '@mui/icons-material/Menu'
import LanguageIcon from '@mui/icons-material/Language'
import AccountCircleIcon from '@mui/icons-material/AccountCircle'
import NotificationsIcon from '@mui/icons-material/Notifications'
import { useAuth } from '@/shared/hooks/useAuth'
import { useTranslation } from 'react-i18next'
import { SUPPORTED_LANGUAGES } from '@/config/constants'
import { changeLanguage } from '@/i18n/i18n'
import { motion } from 'framer-motion'

interface NavbarProps {
  drawerWidth: number
  onDrawerToggle: () => void
}
const Navbar: React.FC<NavbarProps> = ({ drawerWidth, onDrawerToggle }) => {
  const { isAuthenticated, user, logout } = useAuth()
  const { t, i18n } = useTranslation()
  const navigate = useNavigate()
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const [isScrolled, setIsScrolled] = useState(false)
  const [userMenuAnchorEl, setUserMenuAnchorEl] = useState<null | HTMLElement>(null)
  const [langMenuAnchorEl, setLangMenuAnchorEl] = useState<null | HTMLElement>(null)
  const [notificationsAnchorEl, setNotificationsAnchorEl] = useState<null | HTMLElement>(null)
  # Detectar scroll para añadir sombra a la barra
  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10)
    }
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])
  const handleUserMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setUserMenuAnchorEl(event.currentTarget)
  }
  const handleUserMenuClose = () => {
    setUserMenuAnchorEl(null)
  }
  const handleLangMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setLangMenuAnchorEl(event.currentTarget)
  }
  const handleLangMenuClose = () => {
    setLangMenuAnchorEl(null)
  }
  const handleNotificationsOpen = (event: React.MouseEvent<HTMLElement>) => {
    setNotificationsAnchorEl(event.currentTarget)
  }
  const handleNotificationsClose = () => {
    setNotificationsAnchorEl(null)
  }
  const handleLanguageChange = (lang: string) => {
    changeLanguage(lang)
    handleLangMenuClose()
  }
  const handleProfile = () => {
    navigate('/profile')
    handleUserMenuClose()
  }
  const handleSettings = () => {
    navigate('/settings')
    handleUserMenuClose()
  }
  const handleLogout = () => {
    logout()
    handleUserMenuClose()
    navigate('/login')
  }
  return (
    <Slide appear={false} direction="down" in={!isScrolled || !isMobile}>
      <AppBar
        position="fixed"
        elevation={isScrolled ? 4 : 0}
        sx={{
          width: { sm: "calc(100% - " + drawerWidth + "px)" },
          ml: { sm: drawerWidth + "px" },
          boxShadow: isScrolled ? '0 2px 10px rgba(0, 0, 0, 0.1)' : 'none',
          backgroundColor: 'background.paper',
          color: 'text.primary',
          transition: 'box-shadow 0.3s ease-in-out, background-color 0.3s ease-in-out',
          borderBottom: isScrolled ? 'none' : '1px solid rgba(0, 0, 0, 0.06)',
        }}
      >
        <Toolbar sx={{ px: { xs: 1.5, sm: 3 }, py: 0.5, minHeight: '64px' }}>
          # Logo/Brand
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <IconButton
              color="inherit"
              aria-label="open drawer"
              edge="start"
              onClick={onDrawerToggle}
              sx={{ mr: 2, display: { sm: 'none' } }}
              className="scale-in"
            >
              <MenuIcon />
            </IconButton>
            <Typography
              variant="h6"
              noWrap
              component="div"
              sx={{
                fontFamily: 'var(--heading-font-family)',
                fontWeight: 600,
                display: 'flex',
                alignItems: 'center',
                gap: 1
              }}
              className="fade-in"
            >
              <img
                src="/assets/images/logos/dialoom-logo.svg"
                alt="Dialoom"
                height={28}
                style={{ marginRight: '8px' }}
              />
              {t('common.appName')}
            </Typography>
          </Box>
          <Box sx={{ flexGrow: 1 }} />
          {isAuthenticated ? (
            <>
              # Notificaciones
              <Tooltip title={t('profile.notifications')}>
                <IconButton color="inherit" onClick={handleNotificationsOpen}>
                  <Badge badgeContent={3} color="error">
                    <NotificationsIcon />
                  </Badge>
                </IconButton>
              </Tooltip>
              <Menu
                anchorEl={notificationsAnchorEl}
                open={Boolean(notificationsAnchorEl)}
                onClose={handleNotificationsClose}
                transformOrigin={{ horizontal: 'right', vertical: 'top' }}
                anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
                PaperProps={{
                  elevation: 3,
                  sx: {
                    mt: 1.5,
                    minWidth: 280,
                    borderRadius: 2
                  }
                }}
              >
                <MenuItem onClick={handleNotificationsClose}>
                  <Box sx={{ py: 1 }}>
                    <Typography variant="subtitle2">Nueva reserva confirmada</Typography>
                    <Typography variant="body2" color="text.secondary">Hace 10 minutos</Typography>
                  </Box>
                </MenuItem>
                <MenuItem onClick={handleNotificationsClose}>
                  <Box sx={{ py: 1 }}>
                    <Typography variant="subtitle2">Recordatorio: Llamada en 1 hora</Typography>
                    <Typography variant="body2" color="text.secondary">Hace 30 minutos</Typography>
                  </Box>
                </MenuItem>
                <MenuItem onClick={handleNotificationsClose}>
                  <Box sx={{ py: 1 }}>
                    <Typography variant="subtitle2">Pago recibido de Juan Pérez</Typography>
                    <Typography variant="body2" color="text.secondary">Hace 2 horas</Typography>
                  </Box>
                </MenuItem>
              </Menu>
              # Selector de idioma
              <Tooltip title={t('profile.language')}>
                <IconButton color="inherit" onClick={handleLangMenuOpen}>
                  <LanguageIcon />
                </IconButton>
              </Tooltip>
              <Menu
                anchorEl={langMenuAnchorEl}
                open={Boolean(langMenuAnchorEl)}
                onClose={handleLangMenuClose}
                PaperProps={{
                  elevation: 3,
                  sx: { mt: 1.5, borderRadius: 2 }
                }}
              >
                {SUPPORTED_LANGUAGES.map((lang) => (
                  <MenuItem
                    key={lang.code}
                    onClick={() => handleLanguageChange(lang.code)}
                    selected={i18n.language === lang.code}
                    sx={{
                      px: 2,
                      py: 1,
                      '&.Mui-selected': {
                        bgcolor: 'primary.light',
                        color: 'primary.contrastText',
                      }
                    }}
                  >
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <img
                        src={`/assets/images/flags/${lang.code}.svg`}
                        alt={lang.name}
                        width={20}
                        height={15}
                        style={{ borderRadius: 2 }}
                      />
                      {lang.name}
                    </Box>
                  </MenuItem>
                ))}
              </Menu>
              # Menú de usuario
              <motion.div whileTap={{ scale: 0.95 }}>
                <IconButton
                  onClick={handleUserMenuOpen}
                  color="inherit"
                  size="small"
                  sx={{ ml: 2 }}
                >
                  {user?.profileImage ? (
                    <Avatar src={user.profileImage} alt={user.firstName} sx={{ width: 32, height: 32 }} />
                  ) : (
                    <Avatar sx={{ width: 32, height: 32, bgcolor: 'primary.main' }}>
                      {user?.firstName?.[0] || <AccountCircleIcon />}
                    </Avatar>
                  )}
                </IconButton>
              </motion.div>
              <Menu
                anchorEl={userMenuAnchorEl}
                open={Boolean(userMenuAnchorEl)}
                onClose={handleUserMenuClose}
                PaperProps={{
                  elevation: 3,
                  sx: { mt: 1.5, minWidth: 180, borderRadius: 2 }
                }}
              >
                <Box sx={{ px: 2, py: 1, borderBottom: '1px solid', borderColor: 'divider' }}>
                  <Typography variant="subtitle2">{user?.firstName} {user?.lastName}</Typography>
                  <Typography variant="body2" color="text.secondary" noWrap>{user?.email}</Typography>
                </Box>
                <MenuItem onClick={handleProfile} sx={{ py: 1.5 }}>{t('navigation.profile')}</MenuItem>
                <MenuItem onClick={handleSettings} sx={{ py: 1.5 }}>{t('navigation.settings')}</MenuItem>
                <Box sx={{ borderTop: '1px solid', borderColor: 'divider', mt: 1 }}>
                  <MenuItem onClick={handleLogout} sx={{ py: 1.5, color: 'error.main' }}>{t('navigation.logout')}</MenuItem>
                </Box>
              </Menu>
            </>
          ) : (
            <>
              <Button
                color="inherit"
                onClick={() => navigate('/login')}
                sx={{ textTransform: 'none', fontWeight: 'normal' }}
              >
                {t('auth.login')}
              </Button>
              <Button
                variant="contained"
                onClick={() => navigate('/register')}
                sx={{
                  ml: 1,
                  bgcolor: 'primary.main',
                  color: 'white',
                  textTransform: 'none',
                  '&:hover': {
                    bgcolor: 'primary.dark'
                  },
                  display: isMobile ? 'none' : 'block'
                }}
              >
                {t('auth.register')}
              </Button>
            </>
          )}
        </Toolbar>
      </AppBar>
    </Slide>
  )
}
export default React.memo(Navbar)
EOF
  cat > src/shared/components/layout/Sidebar.tsx << 'EOF'
import React, { useMemo } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import {
  Box,
  Divider,
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Typography,
  useTheme,
  Collapse,
} from '@mui/material'
import DashboardIcon from '@mui/icons-material/Dashboard'
import PeopleIcon from '@mui/icons-material/People'
import EventNoteIcon from '@mui/icons-material/EventNote'
import VideocamIcon from '@mui/icons-material/Videocam'
import PaymentIcon from '@mui/icons-material/Payment'
import PersonIcon from '@mui/icons-material/Person'
import SettingsIcon from '@mui/icons-material/Settings'
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings'
import CalendarMonthIcon from '@mui/icons-material/CalendarMonth'
import SupervisorAccountIcon from '@mui/icons-material/SupervisorAccount'
import SchoolIcon from '@mui/icons-material/School'
import ExpandMoreIcon from '@mui/icons-material/ExpandMore'
import ExpandLessIcon from '@mui/icons-material/ExpandLess'
import { useAuth } from '@/shared/hooks/useAuth'
import { useTranslation } from 'react-i18next'
import { UserRole } from '@/shared/types/User'
import { motion } from 'framer-motion'

interface SidebarProps {
  drawerWidth: number
  mobileOpen: boolean
  onDrawerToggle: () => void
}
const Sidebar: React.FC<SidebarProps> = ({
  drawerWidth,
  mobileOpen,
  onDrawerToggle,
}) => {
  const { user } = useAuth()
  const { t } = useTranslation()
  const navigate = useNavigate()
  const location = useLocation()
  const theme = useTheme()
  const [adminOpen, setAdminOpen] = React.useState(location.pathname.startsWith('/admin'));
  
  const isActive = (path: string) => location.pathname === path
  const isAdminRoute = location.pathname.startsWith('/admin')
  const isAdmin = user?.role === UserRole.ADMIN || user?.role === UserRole.SUPERADMIN
  const isHost = user?.role === UserRole.HOST || isAdmin
  
  const handleAdminToggle = () => {
    setAdminOpen(!adminOpen);
  };
  
  # Memoizar los items del menú para evitar re-renderizados innecesarios
  const menuItems = useMemo(() => [
    {
      text: t('navigation.dashboard'),
      icon: <DashboardIcon />,
      path: '/dashboard',
      show: true,
    },
    {
      text: t('navigation.hosts'),
      icon: <PeopleIcon />,
      path: '/hosts',
      show: true,
    },
    {
      text: t('navigation.reservations'),
      icon: <EventNoteIcon />,
      path: '/reservations',
      show: true,
    },
    {
      text: t('navigation.schedule'),
      icon: <CalendarMonthIcon />,
      path: '/schedule',
      show: isHost,
    },
    {
      text: t('navigation.calls'),
      icon: <VideocamIcon />,
      path: '/calls',
      show: true,
    },
    {
      text: t('navigation.payments'),
      icon: <PaymentIcon />,
      path: '/payments',
      show: true,
    },
    {
      text: t('navigation.profile'),
      icon: <PersonIcon />,
      path: '/profile',
      show: true,
    },
    {
      text: t('navigation.settings'),
      icon: <SettingsIcon />,
      path: '/settings',
      show: true,
    },
  ], [t, isHost])
  
  const adminMenuItems = useMemo(() => [
    {
      text: t('admin.dashboard'),
      icon: <DashboardIcon />,
      path: '/admin',
    },
    {
      text: t('admin.users'),
      icon: <PeopleIcon />,
      path: '/admin/users',
    },
    {
      text: t('admin.hosts'),
      icon: <SupervisorAccountIcon />,
      path: '/admin/hosts',
    },
    {
      text: t('admin.payments'),
      icon: <PaymentIcon />,
      path: '/admin/payments',
    },
    {
      text: t('admin.theme'),
      icon: <SettingsIcon />,
      path: '/admin/theme',
    },
    {
      text: t('admin.content'),
      icon: <SchoolIcon />,
      path: '/admin/content',
    },
  ], [t])
  
  const handleNavigate = (path: string) => {
    navigate(path)
    if (window.innerWidth < 600) {
      onDrawerToggle()
    }
  }
  
  const drawer = (
    <div>
      <Toolbar>
        <Box sx={{ display: 'flex', alignItems: 'center' }}>
          <img
            src="/assets/images/logos/dialoom-logo.svg"
            alt="Dialoom"
            width={32}
            height={32}
            style={{ marginRight: '12px' }}
          />
          <Typography
            variant="h6"
            noWrap
            component="div"
            sx={{
              fontFamily: 'var(--heading-font-family)',
              fontWeight: 600
            }}
          >
            {t('common.appName')}
          </Typography>
        </Box>
      </Toolbar>
      <Divider />
      <List sx={{ py: 1 }}>
        {menuItems
          .filter((item) => item.show)
          .map((item) => (
            <motion.div
              key={item.text}
              whileHover={{ x: 4 }}
              transition={{ duration: 0.2 }}
            >
              <ListItem disablePadding>
                <ListItemButton
                  selected={isActive(item.path)}
                  onClick={() => handleNavigate(item.path)}
                  sx={{
                    py: 1.5,
                    px: 3,
                    borderRadius: '0 24px 24px 0',
                    mr: 2,
                    '&.Mui-selected': {
                      bgcolor: 'primary.light',
                      color: 'primary.contrastText',
                      '& .MuiListItemIcon-root': {
                        color: 'primary.contrastText',
                      },
                    },
                    '&.Mui-selected:hover': {
                      bgcolor: 'primary.main',
                    },
                  }}
                >
                  <ListItemIcon
                    sx={{
                      color: isActive(item.path)
                        ? 'primary.contrastText'
                        : undefined,
                      minWidth: 40,
                    }}
                  >
                    {item.icon}
                  </ListItemIcon>
                  <ListItemText primary={item.text} />
                </ListItemButton>
              </ListItem>
            </motion.div>
          ))}
      </List>
      {isAdmin && (
        <>
          <Divider sx={{ my: 2 }} />
          <List sx={{ py: 1 }}>
            <ListItem disablePadding>
              <ListItemButton
                selected={isAdminRoute}
                onClick={handleAdminToggle}
                sx={{
                  py: 1.5,
                  px: 3,
                  borderRadius: '0 24px 24px 0',
                  mr: 2,
                  '&.Mui-selected': {
                    bgcolor: 'secondary.main',
                    color: 'secondary.contrastText',
                    '& .MuiListItemIcon-root': {
                      color: 'secondary.contrastText',
                    },
                  },
                }}
              >
                <ListItemIcon
                  sx={{
                    color: isAdminRoute
                      ? 'secondary.contrastText'
                      : undefined,
                    minWidth: 40,
                  }}
                >
                  <AdminPanelSettingsIcon />
                </ListItemIcon>
                <ListItemText primary={t('navigation.admin')} />
                {adminOpen ? <ExpandLessIcon /> : <ExpandMoreIcon />}
              </ListItemButton>
            </ListItem>
            
            <Collapse in={adminOpen} timeout="auto" unmountOnExit>
              <List component="div" disablePadding>
                {adminMenuItems.map((item) => (
                  <motion.div
                    key={item.path}
                    whileHover={{ x: 4 }}
                    transition={{ duration: 0.2 }}
                  >
                    <ListItem disablePadding>
                      <ListItemButton
                        selected={isActive(item.path)}
                        onClick={() => handleNavigate(item.path)}
                        sx={{
                          py: 1.25,
                          pl: 6,
                          pr: 3,
                          borderRadius: '0 24px 24px 0',
                          mr: 2,
                          '&.Mui-selected': {
                            bgcolor: 'secondary.light',
                            color: 'secondary.contrastText',
                            '& .MuiListItemIcon-root': {
                              color: 'secondary.contrastText',
                            },
                          },
                        }}
                      >
                        <ListItemIcon sx={{ minWidth: 36 }}>
                          {item.icon}
                        </ListItemIcon>
                        <ListItemText
                          primary={item.text}
                          primaryTypographyProps={{ fontSize: '0.9rem' }}
                        />
                      </ListItemButton>
                    </ListItem>
                  </motion.div>
                ))}
              </List>
            </Collapse>
          </List>
        </>
      )}
    </div>
  )
  return (
    <Box
      component="nav"
      sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
    >
      # Mobile drawer
      <Drawer
        variant="temporary"
        open={mobileOpen}
        onClose={onDrawerToggle}
        ModalProps={{
          keepMounted: true, # Mejor rendimiento en dispositivos móviles
        }}
        sx={{
          display: { xs: 'block', sm: 'none' },
          '& .MuiDrawer-paper': {
            boxSizing: 'border-box',
            width: drawerWidth,
            boxShadow: 3,
          },
        }}
      >
        {drawer}
      </Drawer>
      # Desktop drawer
      <Drawer
        variant="permanent"
        sx={{
          display: { xs: 'none', sm: 'block' },
          '& .MuiDrawer-paper': {
            boxSizing: 'border-box',
            width: drawerWidth,
            borderRight: '1px solid rgba(0, 0, 0, 0.08)',
          },
        }}
        open
      >
        {drawer}
      </Drawer>
    </Box>
  )
}
export default React.memo(Sidebar)
EOF
  cat > src/shared/components/layout/Footer.tsx << 'EOF'
import React from 'react'
import { Box, Container, Typography, Link, Divider, IconButton, useTheme, useMediaQuery } from '@mui/material'
import { Link as RouterLink } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import FacebookIcon from '@mui/icons-material/Facebook'
import TwitterIcon from '@mui/icons-material/Twitter'
import InstagramIcon from '@mui/icons-material/Instagram'
import LinkedInIcon from '@mui/icons-material/LinkedIn'

const Footer: React.FC = () => {
  const { t } = useTranslation()
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const currentYear = new Date().getFullYear()
  return (
    <Box
      component="footer"
      sx={{
        py: 3,
        mt: 'auto',
        backgroundColor: 'background.paper',
        borderTop: '1px solid rgba(0, 0, 0, 0.08)',
      }}
    >
      <Container maxWidth="lg">
        <Box
          sx={{
            display: 'flex',
            flexDirection: isMobile ? 'column' : 'row',
            justifyContent: 'space-between',
            alignItems: isMobile ? 'center' : 'flex-start',
            mb: 2,
          }}
        >
          <Box sx={{ mb: isMobile ? 2 : 0 }}>
            <Typography
              variant="h6"
              component="div"
              sx={{
                fontFamily: 'var(--heading-font-family)',
                fontWeight: 600,
                mb: 1,
                display: 'flex',
                alignItems: 'center',
              }}
            >
              <img
                src="/assets/images/logos/dialoom-logo.svg"
                alt="Dialoom"
                width={24}
                height={24}
                style={{ marginRight: '8px' }}
              />
              {t('common.appName')}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Connecting clients with professional mentors
            </Typography>
          </Box>
          <Box sx={{ display: 'flex', gap: 1 }}>
            <IconButton
              color="primary"
              aria-label="facebook"
              component="a"
              href="#"
              target="_blank"
              sx={{
                '&:hover': {
                  transform: 'translateY(-3px)',
                  transition: 'transform 0.2s ease'
                }
              }}
            >
              <FacebookIcon />
            </IconButton>
            <IconButton
              color="primary"
              aria-label="twitter"
              component="a"
              href="#"
              target="_blank"
              sx={{
                '&:hover': {
                  transform: 'translateY(-3px)',
                  transition: 'transform 0.2s ease'
                }
              }}
            >
              <TwitterIcon />
            </IconButton>
            <IconButton
              color="primary"
              aria-label="instagram"
              component="a"
              href="#"
              target="_blank"
              sx={{
                '&:hover': {
                  transform: 'translateY(-3px)',
                  transition: 'transform 0.2s ease'
                }
              }}
            >
              <InstagramIcon />
            </IconButton>
            <IconButton
              color="primary"
              aria-label="linkedin"
              component="a"
              href="#"
              target="_blank"
              sx={{
                '&:hover': {
                  transform: 'translateY(-3px)',
                  transition: 'transform 0.2s ease'
                }
              }}
            >
              <LinkedInIcon />
            </IconButton>
          </Box>
        </Box>
        <Divider sx={{ my: 2 }} />
        <Box
          sx={{
            display: 'flex',
            flexDirection: isMobile ? 'column' : 'row',
            justifyContent: 'space-between',
            alignItems: 'center',
            gap: isMobile ? 1 : 0,
          }}
        >
          <Typography variant="body2" color="text.secondary">
            © {currentYear} Dialoom. {t('common.allRightsReserved')}
          </Typography>
          <Box
            sx={{
              display: 'flex',
              gap: 2,
              mt: isMobile ? 1 : 0,
              flexWrap: 'wrap',
              justifyContent: 'center',
            }}
          >
            <Link component={RouterLink} to="/terms" variant="body2" color="inherit" sx={{
              '&:hover': { color: 'primary.main' }
            }}>
              {t('common.termsAndConditions')}
            </Link>
            <Link component={RouterLink} to="/privacy" variant="body2" color="inherit" sx={{
              '&:hover': { color: 'primary.main' }
            }}>
              {t('common.privacyPolicy')}
            </Link>
            <Link component={RouterLink} to="/contact" variant="body2" color="inherit" sx={{
              '&:hover': { color: 'primary.main' }
            }}>
              {t('common.contactUs')}
            </Link>
          </Box>
        </Box>
      </Container>
    </Box>
  )
}
export default React.memo(Footer)
EOF
  # Crear componente de Calendario Reactivo
  mkdir -p src/features/reservations/components
  cat > src/features/reservations/components/Calendar.tsx << 'EOF'
import React, { useState, useCallback, useMemo } from 'react';
import { Calendar as BigCalendar, momentLocalizer } from 'react-big-calendar';
import moment from 'moment';
import 'react-big-calendar/lib/css/react-big-calendar.css';
import {
  Paper,
  Box,
  Typography,
  Chip,
  useTheme,
  useMediaQuery,
  IconButton,
  Menu,
  MenuItem,
} from '@mui/material';
import TodayIcon from '@mui/icons-material/Today';
import NavigateBeforeIcon from '@mui/icons-material/NavigateBefore';
import NavigateNextIcon from '@mui/icons-material/NavigateNext';
import { useTranslation } from 'react-i18next';
import { motion } from 'framer-motion';

const localizer = momentLocalizer(moment);

# Tipos personalizados para eventos
interface CalendarEvent {
  id: string;
  title: string;
  start: Date;
  end: Date;
  hostId?: string;
  hostName?: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  isHost?: boolean;
}
interface CalendarProps {
  events: CalendarEvent[];
  onEventSelect?: (event: CalendarEvent) => void;
  onSlotSelect?: (slotInfo: { start: Date; end: Date }) => void;
  isHost?: boolean;
}
const Calendar: React.FC<CalendarProps> = ({
  events,
  onEventSelect,
  onSlotSelect,
  isHost = false,
}) => {
  const { t } = useTranslation();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const [view, setView] = useState(isMobile ? 'day' : 'week');
  const [date, setDate] = useState(new Date());
  const [menuAnchorEl, setMenuAnchorEl] = useState<null | HTMLElement>(null);
  # Animación para eventos al cambiar de vista
  const eventPropGetter = useCallback(
    (event: CalendarEvent) => {
      let backgroundColor;
      let borderColor;
      let color = '#fff';
      # Colores basados en estado
      switch (event.status) {
        case 'confirmed':
          backgroundColor = theme.palette.primary.main;
          borderColor = theme.palette.primary.dark;
          break;
        case 'pending':
          backgroundColor = theme.palette.warning.main;
          borderColor = theme.palette.warning.dark;
          break;
        case 'completed':
          backgroundColor = theme.palette.success.main;
          borderColor = theme.palette.success.dark;
          break;
        case 'cancelled':
          backgroundColor = theme.palette.error.light;
          borderColor = theme.palette.error.main;
          color = theme.palette.error.contrastText;
          break;
        default:
          backgroundColor = theme.palette.primary.main;
          borderColor = theme.palette.primary.dark;
      }
      return {
        style: {
          backgroundColor,
          borderColor,
          color,
          borderRadius: '8px',
          border: 'none',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          transition: 'transform 0.2s ease, box-shadow 0.2s ease',
          boxShadow: '0 2px 6px rgba(0, 0, 0, 0.15)',
          '&:hover': {
            transform: 'translateY(-2px)',
            boxShadow: '0 4px 10px rgba(0, 0, 0, 0.2)',
          },
          cursor: 'pointer',
        },
      };
    },
    [theme]
  );
  # Componente personalizado para eventos
  const EventComponent = ({ event }: { event: CalendarEvent }) => (
    <motion.div
      initial={{ opacity: 0, y: 5 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
      style={{ padding: '4px 8px', height: '100%' }}
    >
      <Typography variant="caption" noWrap fontWeight="medium">
        {event.title}
      </Typography>
      {!isMobile && (
        <Typography variant="caption" display="block" noWrap>
          {event.isHost ? t('reservations.with') : ''}{' '}
          {event.hostName || ''}
        </Typography>
      )}
    </motion.div>
  );
  # Barra de herramientas personalizada
  const CustomToolbar = () => (
    <Box
      sx={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        p: 2,
        borderBottom: '1px solid',
        borderColor: 'divider',
        flexWrap: 'wrap',
        gap: 1,
      }}
    >
      <Box display="flex" alignItems="center">
        <IconButton onClick={() => setDate(new Date())}>
          <TodayIcon />
        </IconButton>
        <IconButton onClick={() => handleNavigate('PREV')}>
          <NavigateBeforeIcon />
        </IconButton>
        <IconButton onClick={() => handleNavigate('NEXT')}>
          <NavigateNextIcon />
        </IconButton>
        <Typography variant="h6" sx={{ ml: 1 }}>
          {moment(date).format(view === 'month' ? 'MMMM YYYY' : 'MMM D, YYYY')}
        </Typography>
      </Box>
      <Box display="flex" gap={1}>
        <Chip
          label={t('common.day')}
          onClick={() => setView('day')}
          color={view === 'day' ? 'primary' : 'default'}
          variant={view === 'day' ? 'filled' : 'outlined'}
        />
        <Chip
          label={t('common.week')}
          onClick={() => setView('week')}
          color={view === 'week' ? 'primary' : 'default'}
          variant={view === 'week' ? 'filled' : 'outlined'}
        />
        <Chip
          label={t('common.month')}
          onClick={() => setView('month')}
          color={view === 'month' ? 'primary' : 'default'}
          variant={view === 'month' ? 'filled' : 'outlined'}
        />
      </Box>
    </Box>
  );
  const handleNavigate = (action: 'PREV' | 'TODAY' | 'NEXT') => {
    const newDate = new Date(date);
    if (action === 'PREV') {
      if (view === 'day') newDate.setDate(newDate.getDate() - 1);
      else if (view === 'week') newDate.setDate(newDate.getDate() - 7);
      else newDate.setMonth(newDate.getMonth() - 1);
    } else if (action === 'NEXT') {
      if (view === 'day') newDate.setDate(newDate.getDate() + 1);
      else if (view === 'week') newDate.setDate(newDate.getDate() + 7);
      else newDate.setMonth(newDate.getMonth() + 1);
    } else {
      setDate(new Date());
      return;
    }
    setDate(newDate);
  };
  return (
    <Paper
      elevation={0}
      sx={{
        height: 700,
        maxHeight: 'calc(100vh - 200px)',
        overflow: 'hidden',
        borderRadius: 3,
        border: '1px solid',
        borderColor: 'divider',
        transition: 'all 0.3s ease',
        '&:hover': {
          boxShadow: '0 4px 20px rgba(0, 0, 0, 0.08)',
        },
      }}
    >
      <CustomToolbar />
      <Box sx={{ height: 'calc(100% - 72px)' }}>
        <BigCalendar
          localizer={localizer}
          events={events}
          startAccessor="start"
          endAccessor="end"
          view={view as any}
          date={date}
          onNavigate={(newDate) => setDate(newDate)}
          onView={(newView) => setView(newView)}
          components={{
            event: EventComponent as any,
          }}
          eventPropGetter={eventPropGetter as any}
          onSelectEvent={onEventSelect}
          onSelectSlot={onSlotSelect}
          selectable={isHost}
          popup
          formats={{
            timeGutterFormat: (date: Date) => moment(date).format('HH:mm'),
            eventTimeRangeFormat: ({ start, end }: { start: Date; end: Date }) =>
              `${moment(start).format('HH:mm')} - ${moment(end).format('HH:mm')}`,
          }}
          messages={{
            today: t('common.today'),
            previous: t('common.previous'),
            next: t('common.next'),
            month: t('common.month'),
            week: t('common.week'),
            day: t('common.day'),
            agenda: t('common.agenda'),
            date: t('common.date'),
            time: t('common.time'),
            event: t('common.event'),
            noEventsInRange: t('reservations.noTimeSlots'),
          }}
        />
      </Box>
    </Paper>
  );
};
export default Calendar;
EOF
  # Crear módulo de videollamadas optimizado con Agora
  mkdir -p src/features/calls/components
  cat > src/features/calls/components/CallInterface.tsx << 'EOF'
import React, { useState, useEffect, useRef } from 'react';
import {
  Box,
  Paper,
  Grid,
  IconButton,
  Typography,
  Tooltip,
  Badge,
  Avatar,
  useTheme,
  useMediaQuery,
  CircularProgress,
} from '@mui/material';
import MicIcon from '@mui/icons-material/Mic';
import MicOffIcon from '@mui/icons-material/MicOff';
import VideocamIcon from '@mui/icons-material/Videocam';
import VideocamOffIcon from '@mui/icons-material/VideocamOff';
import CallEndIcon from '@mui/icons-material/CallEnd';
import ScreenShareIcon from '@mui/icons-material/ScreenShare';
import StopScreenShareIcon from '@mui/icons-material/StopScreenShare';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import ChatIcon from '@mui/icons-material/Chat';
import { useTranslation } from 'react-i18next';
import { motion } from 'framer-motion';

interface CallInterfaceProps {
  channelName: string;
  token: string;
  uid: number;
  role: 'host' | 'client';
  hostName: string;
  hostImage?: string;
  clientName: string;
  clientImage?: string;
  onCallEnd: () => void;
}
# Componente de videollamada con efectos visuales y UI responsiva
const CallInterface: React.FC<CallInterfaceProps> = ({
  channelName,
  token,
  uid,
  role,
  hostName,
  hostImage,
  clientName,
  clientImage,
  onCallEnd
}) => {
  const { t } = useTranslation();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const localVideoRef = useRef<HTMLDivElement>(null);
  const remoteVideoRef = useRef<HTMLDivElement>(null);
  # Estados para controlar la interfaz
  const [isMuted, setIsMuted] = useState(false);
  const [isVideoOff, setIsVideoOff] = useState(false);
  const [isScreenSharing, setIsScreenSharing] = useState(false);
  const [isChatOpen, setIsChatOpen] = useState(false);
  const [callDuration, setCallDuration] = useState(0);
  const [connecting, setConnecting] = useState(true);
  const [remoteUsers, setRemoteUsers] = useState<any[]>([]);
  # Simulación de inicialización de llamada
  useEffect(() => {
    # Simulamos la conexión a Agora (en producción esto usaría el SDK real)
    const timer = setTimeout(() => {
      setConnecting(false);
      # Simulamos que hay un usuario remoto conectado
      setRemoteUsers([{ hasVideo: true, hasAudio: true }]);
    }, 3000);
    # Temporizador para duración de llamada
    const durationTimer = setInterval(() => {
      setCallDuration(prev => prev + 1);
    }, 1000);
    return () => {
      clearTimeout(timer);
      clearInterval(durationTimer);
    };
  }, []);
  # Control de micrófono
  const handleToggleMic = () => {
    setIsMuted(prev => !prev);
  };
  # Control de cámara
  const handleToggleCamera = () => {
    setIsVideoOff(prev => !prev);
  };
  # Control de compartir pantalla
  const handleToggleScreenShare = () => {
    setIsScreenSharing(prev => !prev);
  };
  # Formatear duración de llamada
  const formatDuration = (seconds: number) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hours > 0 ? `${hours}:` : ''}${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };
  # Renderizar interfaces de video
  return (
    <Box sx={{ height: '100vh', display: 'flex', flexDirection: 'column', bgcolor: '#121212' }}>
      # Pantalla de conexión
      {connecting && (
        <Box
          sx={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            bgcolor: 'rgba(0,0,0,0.8)',
            zIndex: 10,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            flexDirection: 'column',
            gap: 2,
          }}
        >
          <CircularProgress size={60} thickness={5} sx={{ color: 'primary.main' }} />
          <Typography variant="h6" color="white">
            {t('calls.connecting')}
          </Typography>
        </Box>
      )}
      # Área principal de video
      <Grid container sx={{ flex: 1, position: 'relative' }}>
        # Video remoto a pantalla completa
        <Grid item xs={12} sx={{ height: '100%', position: 'relative' }}>
          <Box
            sx={{
              width: '100%',
              height: '100%',
              bgcolor: 'black',
              position: 'relative',
              overflow: 'hidden',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
            ref={remoteVideoRef}
          >
            # Si no hay conexión remota o la cámara remota está apagada
            {(remoteUsers.length === 0 || !remoteUsers[0]?.hasVideo) ? (
              <Box
                sx={{
                  width: '100%',
                  height: '100%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexDirection: 'column',
                  gap: 2,
                }}
              >
                <Avatar
                  src={role === 'host' ? clientImage || '/assets/images/avatars/default-avatar.svg' : hostImage || '/assets/images/avatars/default-avatar.svg'}
                  sx={{ width: 120, height: 120 }}
                />
                <Typography variant="h5" color="white">
                  {role === 'host'
                    ? t('calls.waitingForParticipant')
                    : t('calls.waitingForHost')}
                </Typography>
              </Box>
            ) : (
              # Placeholder para el video remoto (en producción sería renderizado por el SDK de Agora)
              <Box sx={{
                position: 'absolute',
                width: '100%',
                height: '100%',
                bgcolor: '#333',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                '&::before': {
                  content: '""',
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  background: 'linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.5))',
                }
              }}>
                <Typography variant="h6" color="white" sx={{ zIndex: 1 }}>
                  {role === 'host' ? clientName : hostName}
                </Typography>
              </Box>
            )}
          </Box>
          # Información de duración de llamada
          <Box
            sx={{
              position: 'absolute',
              top: 16,
              left: 16,
              borderRadius: 4,
              bgcolor: 'rgba(0,0,0,0.5)',
              color: 'white',
              px: 2,
              py: 0.5,
              display: 'flex',
              alignItems: 'center',
              gap: 1,
            }}
          >
            <Typography variant="body2" fontWeight="medium">
              {formatDuration(callDuration)}
            </Typography>
          </Box>
          # Video local en pequeño
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.3 }}
            style={{
              position: 'absolute',
              right: 16,
              bottom: 100,
              width: isMobile ? 100 : 180,
              height: isMobile ? 150 : 240,
              borderRadius: 12,
              overflow: 'hidden',
              boxShadow: '0 8px 16px rgba(0,0,0,0.4)',
              zIndex: 2,
            }}
          >
            <Box
              sx={{
                width: '100%',
                height: '100%',
                bgcolor: '#333',
                position: 'relative',
              }}
              ref={localVideoRef}
            >
              {isVideoOff ? (
                <Box
                  sx={{
                    width: '100%',
                    height: '100%',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Avatar
                    src={role === 'host' ? hostImage || '/assets/images/avatars/default-avatar.svg' : clientImage || '/assets/images/avatars/default-avatar.svg'}
                    sx={{ width: 60, height: 60 }}
                  />
                </Box>
              ) : (
                # Placeholder para el video local (en producción sería renderizado por el SDK de Agora)
                <Box sx={{
                  width: '100%',
                  height: '100%',
                  bgcolor: '#555',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}>
                  <Typography variant="body2" color="white">
                    {role === 'host' ? hostName : clientName}
                  </Typography>
                </Box>
              )}
            </Box>
          </motion.div>
        </Grid>
      </Grid>
      # Controles de llamada
      <Paper
        elevation={10}
        sx={{
          borderRadius: { xs: 0, sm: '24px 24px 0 0' },
          p: 2,
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          gap: { xs: 1, sm: 3 },
          bgcolor: 'rgba(255,255,255,0.95)',
          backdropFilter: 'blur(10px)',
        }}
      >
        <Tooltip title={isMuted ? t('calls.micOn') : t('calls.micOff')}>
          <IconButton
            onClick={handleToggleMic}
            sx={{
              bgcolor: isMuted ? 'error.main' : 'action.hover',
              color: isMuted ? 'white' : 'text.primary',
              '&:hover': {
                bgcolor: isMuted ? 'error.dark' : 'action.selected',
              },
              transition: 'all 0.2s',
              width: { xs: 40, sm: 56 },
              height: { xs: 40, sm: 56 },
            }}
          >
            {isMuted ? <MicOffIcon /> : <MicIcon />}
          </IconButton>
        </Tooltip>
        <Tooltip title={isVideoOff ? t('calls.cameraOn') : t('calls.cameraOff')}>
          <IconButton
            onClick={handleToggleCamera}
            sx={{
              bgcolor: isVideoOff ? 'error.main' : 'action.hover',
              color: isVideoOff ? 'white' : 'text.primary',
              '&:hover': {
                bgcolor: isVideoOff ? 'error.dark' : 'action.selected',
              },
              transition: 'all 0.2s',
              width: { xs: 40, sm: 56 },
              height: { xs: 40, sm: 56 },
            }}
          >
            {isVideoOff ? <VideocamOffIcon /> : <VideocamIcon />}
          </IconButton>
        </Tooltip>
        <Tooltip title={isScreenSharing ? t('calls.stopScreenShare') : t('calls.screenShare')}>
          <IconButton
            onClick={handleToggleScreenShare}
            sx={{
              bgcolor: isScreenSharing ? 'warning.main' : 'action.hover',
              color: isScreenSharing ? 'white' : 'text.primary',
              '&:hover': {
                bgcolor: isScreenSharing ? 'warning.dark' : 'action.selected',
              },
              transition: 'all 0.2s',
              width: { xs: 40, sm: 56 },
              height: { xs: 40, sm: 56 },
            }}
          >
            {isScreenSharing ? <StopScreenShareIcon /> : <ScreenShareIcon />}
          </IconButton>
        </Tooltip>
        <Tooltip title={t('calls.chatToggle')}>
          <IconButton
            onClick={() => setIsChatOpen(prev => !prev)}
            sx={{
              bgcolor: isChatOpen ? 'primary.main' : 'action.hover',
              color: isChatOpen ? 'white' : 'text.primary',
              '&:hover': {
                bgcolor: isChatOpen ? 'primary.dark' : 'action.selected',
              },
              transition: 'all 0.2s',
              width: { xs: 40, sm: 56 },
              height: { xs: 40, sm: 56 },
            }}
          >
            <Badge color="error" badgeContent={3} invisible={isChatOpen}>
              <ChatIcon />
            </Badge>
          </IconButton>
        </Tooltip>
        <Tooltip title={t('calls.endCall')}>
          <motion.div whileTap={{ scale: 0.95 }}>
            <IconButton
              onClick={onCallEnd}
              sx={{
                bgcolor: 'error.main',
                color: 'white',
                '&:hover': {
                  bgcolor: 'error.dark',
                },
                transition: 'all 0.2s',
                width: { xs: 48, sm: 64 },
                height: { xs: 48, sm: 64 },
              }}
            >
              <CallEndIcon fontSize={isMobile ? 'medium' : 'large'} />
            </IconButton>
          </motion.div>
        </Tooltip>
      </Paper>
    </Box>
  );
};
export default CallInterface;
EOF
  # Crear tipos básicos
  mkdir -p src/shared/types
  cat > src/shared/types/User.ts << 'EOF'
export enum UserRole {
  USER = 'user',
  HOST = 'host',
  ADMIN = 'admin',
  SUPERADMIN = 'superadmin',
}
export interface User {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  role: UserRole;
  isVerified: boolean;
  isBanned: boolean;
  twoFactorEnabled: boolean;
  profileImage?: string;
  phoneNumber?: string;
  preferredLanguage: string;
  timezone?: string;
  points: number;
  level: number;
  stripeCustomerId?: string;
  createdAt: Date;
  updatedAt: Date;
}
export interface Education {
  id: string;
  userId: string;
  institution: string;
  degree?: string;
  fieldOfStudy?: string;
  startDate: Date;
  endDate?: Date;
  isPresent: boolean;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}
export interface WorkExperience {
  id: string;
  userId: string;
  company: string;
  position: string;
  startDate: Date;
  endDate?: Date;
  isPresent: boolean;
  description?: string;
  location?: string;
  website?: string;
  createdAt: Date;
  updatedAt: Date;
}
export interface SocialProfile {
  id: string;
  userId: string;
  type: 'linkedin' | 'twitter' | 'facebook' | 'github' | 'website' | 'other';
  url: string;
  username?: string;
  createdAt: Date;
  updatedAt: Date;
}
EOF
  cat > src/shared/types/Host.ts << 'EOF'
import { User } from './User';

export interface Host {
  userId: string;
  user: {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
    profileImage?: string;
  };
  bio?: string;
  hourlyRate: number;
  isVerified: boolean;
  isFeatured: boolean;
  stripeConnectId?: string;
  profileImage?: string;
  bannerImage?: string;
  specialties: string[];
  languages: string[];
  totalSessions: number;
  averageRating: number;
  responseRate?: number;
  location?: string;
  website?: string;
  createdAt: Date;
  updatedAt: Date;
}
export interface AvailabilitySlot {
  id: string;
  hostId: string;
  day: number; # 0 = domingo, 6 = sábado
  startTime: string; # formato HH:MM
  endTime: string; # formato HH:MM
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}
export interface Review {
  id: string;
  reservationId: string;
  userId: string;
  hostId: string;
  rating: number;
  comment?: string;
  isHostReview: boolean; # true si es una reseña del anfitrión al cliente
  createdAt: Date;
  updatedAt: Date;
  user?: {
    id: string;
    firstName: string;
    lastName: string;
    profileImage?: string;
  };
}
EOF
  cat > src/shared/types/ThemeSettings.ts << 'EOF'
export interface ThemeSettings {
  id: string;
  primaryColor: string;
  secondaryColor: string;
  backgroundColor: string;
  surfaceColor: string;
  errorColor: string;
  successColor: string;
  warningColor: string;
  infoColor: string;
  fontFamily: string;
  headingFontFamily: string;
  baseFontSize: string;
  borderRadius: string;
  customCss?: string;
  logoUrl?: string;
  faviconUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}
EOF
  # Crear hooks personalizados
  mkdir -p src/shared/hooks
  cat > src/shared/hooks/useAuth.ts << 'EOF'
import { useContext } from 'react';
import { AuthContext } from '@/shared/contexts/AuthContext';

export const useAuth = () => {
  return useContext(AuthContext);
};
EOF
  cat > src/shared/hooks/useTheme.ts << 'EOF'
import { useContext } from 'react';
import { ThemeContext } from '@/shared/contexts/ThemeProvider';

export const useTheme = () => {
  return useContext(ThemeContext);
};
EOF
  cat > src/shared/hooks/useI18n.ts << 'EOF'
import { useTranslation } from 'react-i18next';
import { useCallback } from 'react';
import { SUPPORTED_LANGUAGES } from '@/config/constants';
import { changeLanguage } from '@/i18n/i18n';

export const useI18n = () => {
  const { t, i18n } = useTranslation();

  const handleChangeLanguage = useCallback((lng: string) => {
    changeLanguage(lng);
  }, []);
  return {
    t,
    i18n,
    language: i18n.language,
    changeLanguage: handleChangeLanguage,
    supportedLanguages: SUPPORTED_LANGUAGES,
  };
};
EOF
  log_info "Servicios de API creados correctamente."
}

# Crear componente StyleGuidePage para el desarrollo
create_style_guide() {
  log_step "Creando página de guía de estilo..."
  mkdir -p src/features/admin/pages/theme
  cat > src/features/admin/pages/theme/StyleGuidePage.tsx << 'EOF'
import React, { useState } from 'react';
import {
  Box,
  Typography,
  Paper,
  Grid,
  Button,
  TextField,
  Switch,
  FormControlLabel,
  Slider,
  InputLabel,
  MenuItem,
  FormControl,
  Select,
  Divider,
  Card,
  CardContent,
  CardActions,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Alert,
  Chip,
  Avatar,
  IconButton,
  Badge,
} from '@mui/material';
import {
  ExpandMore as ExpandMoreIcon,
  Favorite as FavoriteIcon,
  Add as AddIcon,
  Mail as MailIcon,
} from '@mui/icons-material';
import { motion } from 'framer-motion';
import { useTheme } from '@/shared/hooks/useTheme';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router-dom';

const StyleGuidePage: React.FC = () => {
  const { t } = useTranslation();
  const { theme, themeSettings } = useTheme();
  const [expanded, setExpanded] = useState<string | false>(false);
  const handleAccordionChange = (panel: string) => (event: React.SyntheticEvent, isExpanded: boolean) => {
    setExpanded(isExpanded ? panel : false);
  };
  const colorVariants = [
    { name: 'Primary', color: theme.palette.primary.main, textColor: theme.palette.primary.contrastText },
    { name: 'Secondary', color: theme.palette.secondary.main, textColor: theme.palette.secondary.contrastText },
    { name: 'Error', color: theme.palette.error.main, textColor: theme.palette.error.contrastText },
    { name: 'Warning', color: theme.palette.warning.main, textColor: theme.palette.warning.contrastText },
    { name: 'Success', color: theme.palette.success.main, textColor: theme.palette.success.contrastText },
    { name: 'Info', color: theme.palette.info.main, textColor: theme.palette.info.contrastText },
  ];
  return (
    <Box sx={{ maxWidth: 1200, margin: '0 auto', py: 4 }}>
      <Typography variant="h3" component="h1" gutterBottom>
        Dialoom Style Guide
      </Typography>
      <Grid container spacing={6}>
        # Colores
        <Grid item xs={12}>
          <Paper sx={{ p: 3, mb: 4 }}>
            <Typography variant="h4" gutterBottom>
              Colors
            </Typography>
            <Grid container spacing={2}>
              {colorVariants.map((variant) => (
                <Grid item xs={6} sm={4} md={2} key={variant.name}>
                  <motion.div
                    whileHover={{ y: -5, boxShadow: '0 10px 20px rgba(0,0,0,0.1)' }}
                    transition={{ duration: 0.2 }}
                  >
                    <Box
                      sx={{
                        bgcolor: variant.color,
                        color: variant.textColor,
                        height: 100,
                        borderRadius: 2,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        boxShadow: 1,
                      }}
                    >
                      <Typography variant="subtitle1">{variant.name}</Typography>
                    </Box>
                  </motion.div>
                </Grid>
              ))}
            </Grid>
          </Paper>
        </Grid>
        # Tipografía
        <Grid item xs={12}>
          <Paper sx={{ p: 3, mb: 4 }}>
            <Typography variant="h4" gutterBottom>
              Typography
            </Typography>
            <Box sx={{ mb: 3 }}>
              <Typography variant="h1" gutterBottom>h1. Dialoom Heading</Typography>
              <Typography variant="h2" gutterBottom>h2. Dialoom Heading</Typography>
              <Typography variant="h3" gutterBottom>h3. Dialoom Heading</Typography>
              <Typography variant="h4" gutterBottom>h4. Dialoom Heading</Typography>
              <Typography variant="h5" gutterBottom>h5. Dialoom Heading</Typography>
              <Typography variant="h6" gutterBottom>h6. Dialoom Heading</Typography>
              <Typography variant="subtitle1" gutterBottom>
                subtitle1. Lorem ipsum dolor sit amet, consectetur adipisicing elit.
              </Typography>
              <Typography variant="subtitle2" gutterBottom>
                subtitle2. Lorem ipsum dolor sit amet, consectetur adipisicing elit.
              </Typography>
              <Typography variant="body1" gutterBottom>
                body1. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos
                blanditiis tenetur unde suscipit.
              </Typography>
              <Typography variant="body2" gutterBottom>
                body2. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quos
                blanditiis tenetur unde suscipit.
              </Typography>
              <Typography variant="button" display="block" gutterBottom>
                button text
              </Typography>
              <Typography variant="caption" display="block" gutterBottom>
                caption text
              </Typography>
              <Typography variant="overline" display="block" gutterBottom>
                overline text
              </Typography>
            </Box>
          </Paper>
        </Grid>
        # Botones
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, mb: 4, height: '100%' }}>
            <Typography variant="h4" gutterBottom>
              Buttons
            </Typography>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mb: 3 }}>
              <Box>
                <Button variant="contained">Primary</Button>{' '}
                <Button variant="contained" color="secondary">Secondary</Button>{' '}
                <Button variant="contained" color="success">Success</Button>{' '}
                <Button variant="contained" color="error">Error</Button
              </Box>
              <Box>
                <Button variant="outlined">Primary</Button>{' '}
                <Button variant="outlined" color="secondary">Secondary</Button>{' '}
                <Button variant="outlined" color="success">Success</Button>{' '}
                <Button variant="outlined" color="error">Error</Button>
              </Box>
              <Box>
                <Button variant="text">Primary</Button>{' '}
                <Button variant="text" color="secondary">Secondary</Button>{' '}
                <Button variant="text" color="success">Success</Button>{' '}
                <Button variant="text" color="error">Error</Button>
              </Box>
              <Box>
                <Button size="small" variant="contained">Small</Button>{' '}
                <Button size="medium" variant="contained">Medium</Button>{' '}
                <Button size="large" variant="contained">Large</Button>
              </Box>
              <Box>
                <Button variant="contained" startIcon={<AddIcon />}>
                  Start Icon
                </Button>{' '}
                <Button variant="contained" endIcon={<AddIcon />}>
                  End Icon
                </Button>
              </Box>
              <Box>
                <motion.div whileTap={{ scale: 0.95 }} style={{ display: 'inline-block' }}>
                  <Button variant="contained" sx={{ borderRadius: 50, px: 3 }}>
                    Animated Button
                  </Button>
                </motion.div>
              </Box>
              <Box>
                <IconButton aria-label="add">
                  <AddIcon />
                </IconButton>{' '}
                <IconButton aria-label="favorite" color="primary">
                  <FavoriteIcon />
                </IconButton>{' '}
                <IconButton aria-label="mail" color="secondary">
                  <MailIcon />
                </IconButton>
              </Box>
            </Box>
          </Paper>
        </Grid>
        # Formularios
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, mb: 4, height: '100%' }}>
            <Typography variant="h4" gutterBottom>
              Form Controls
            </Typography>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
              <TextField label="Standard" variant="outlined" />
              <TextField label="Filled" variant="filled" />
              <TextField label="Standard" variant="standard" />
              <TextField
                label="Multiline"
                multiline
                rows={2}
                defaultValue="Default Value"
              />
              <FormControl fullWidth>
                <InputLabel id="select-label">Select</InputLabel>
                <Select
                  labelId="select-label"
                  value="option1"
                  label="Select"
                >
                  <MenuItem value="option1">Option 1</MenuItem>
                  <MenuItem value="option2">Option 2</MenuItem>
                  <MenuItem value="option3">Option 3</MenuItem>
                </Select>
              </FormControl>
              <FormControlLabel
                control={<Switch defaultChecked />}
                label="Switch Example"
              />
              <Box sx={{ width: '100%' }}>
                <Typography>Slider</Typography>
                <Slider
                  defaultValue={30}
                  valueLabelDisplay="auto"
                  step={10}
                  marks
                  min={0}
                  max={100}
                />
              </Box>
            </Box>
          </Paper>
        </Grid>
        # Tarjetas y Contenedores
        <Grid item xs={12}>
          <Paper sx={{ p: 3, mb: 4 }}>
            <Typography variant="h4" gutterBottom>
              Cards & Containers
            </Typography>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6} md={4}>
                <motion.div whileHover={{ y: -5 }} transition={{ duration: 0.2 }}>
                  <Card sx={{ maxWidth: 345 }}>
                    <img
                      src="/assets/images/logos/dialoom-logo.svg"
                      alt="Dialoom Placeholder"
                      style={{ width: '100%', height: 200, objectFit: 'cover', background: '#f0f0f0' }}
                    />
                    <CardContent>
                      <Typography gutterBottom variant="h5" component="div">
                        Card Title
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        This is an example card with some sample content. Cards are used
                        throughout the Dialoom interface for displaying content.
                      </Typography>
                    </CardContent>
                    <CardActions>
                      <Button size="small">Action 1</Button>
                      <Button size="small">Action 2</Button>
                    </CardActions>
                  </Card>
                </motion.div>
              </Grid>
              <Grid item xs={12} sm={6} md={4}>
                <Box sx={{ mb: 2 }}>
                  <Accordion expanded={expanded === 'panel1'} onChange={handleAccordionChange('panel1')}>
                    <AccordionSummary expandIcon={<ExpandMoreIcon />}>
                      <Typography>Accordion 1</Typography>
                    </AccordionSummary>
                    <AccordionDetails>
                      <Typography>
                        This is the content of accordion 1. It can contain any elements.
                      </Typography>
                    </AccordionDetails>
                  </Accordion>
                  <Accordion expanded={expanded === 'panel2'} onChange={handleAccordionChange('panel2')}>
                    <AccordionSummary expandIcon={<ExpandMoreIcon />}>
                      <Typography>Accordion 2</Typography>
                    </AccordionSummary>
                    <AccordionDetails>
                      <Typography>
                        This is the content of accordion 2. It can contain any elements.
                      </Typography>
                    </AccordionDetails>
                  </Accordion>
                </Box>
                <Alert severity="success" sx={{ mb: 1 }}>This is a success alert!</Alert>
                <Alert severity="info" sx={{ mb: 1 }}>This is an info alert!</Alert>
                <Alert severity="warning" sx={{ mb: 1 }}>This is a warning alert!</Alert>
                <Alert severity="error">This is an error alert!</Alert>
              </Grid>
              <Grid item xs={12} sm={6} md={4}>
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                  <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                    <Chip label="Basic" />
                    <Chip label="Primary" color="primary" />
                    <Chip label="Secondary" color="secondary" />
                    <Chip
                      avatar={<Avatar>D</Avatar>}
                      label="With Avatar"
                      variant="outlined"
                    />
                    <Chip
                      label="Deletable"
                      onDelete={() => {}}
                    />
                    <Chip
                      icon={<FavoriteIcon />}
                      label="With Icon"
                      color="error"
                    />
                  </Box>
                  <Divider />
                  <Box sx={{ display: 'flex', gap: 2 }}>
                    <Badge badgeContent={4} color="primary">
                      <MailIcon />
                    </Badge>
                    <Badge badgeContent={100} color="secondary" max={99}>
                      <MailIcon />
                    </Badge>
                    <Badge
                      overlap="circular"
                      anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
                      badgeContent={
                        <Avatar
                          sx={{ width: 22, height: 22, border: '2px solid white' }}
                        >
                          +
                        </Avatar>
                      }
                    >
                      <Avatar sx={{ width: 40, height: 40 }}>D</Avatar>
                    </Badge>
                  </Box>
                  <Divider />
                  <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                    <Avatar>D</Avatar>
                    <Avatar sx={{ bgcolor: 'primary.main' }}>DL</Avatar>
                    <Avatar src="/assets/images/avatars/default-avatar.svg" />
                    <Avatar sx={{ bgcolor: 'secondary.main' }}>
                      <FavoriteIcon />
                    </Avatar>
                  </Box>
                </Box>
              </Grid>
            </Grid>
          </Paper>
        </Grid>
        # Animaciones
        <Grid item xs={12}>
          <Paper sx={{ p: 3, mb: 4 }}>
            <Typography variant="h4" gutterBottom>
              Animations
            </Typography>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6} md={3}>
                <Typography variant="h6" gutterBottom>Hover Scale</Typography>
                <motion.div
                  whileHover={{ scale: 1.05 }}
                  transition={{ type: 'spring', stiffness: 400, damping: 10 }}
                >
                  <Paper
                    sx={{
                      p: 2,
                      textAlign: 'center',
                      height: 100,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      cursor: 'pointer',
                    }}
                  >
                    Hover Me
                  </Paper>
                </motion.div>
              </Grid>
              <Grid item xs={12} sm={6} md={3}>
                <Typography variant="h6" gutterBottom>Rotate</Typography>
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
                  style={{ display: 'inline-flex' }}
                >
                  <Paper
                    sx={{
                      p: 2,
                      width: 100,
                      height: 100,
                      borderRadius: '50%',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    <FavoriteIcon color="error" fontSize="large" />
                  </Paper>
                </motion.div>
              </Grid>
              <Grid item xs={12} sm={6} md={3}>
                <Typography variant="h6" gutterBottom>Fade In</Typography>
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ duration: 1, repeat: Infinity, repeatType: 'reverse' }}
                >
                  <Paper
                    sx={{
                      p: 2,
                      textAlign: 'center',
                      height: 100,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    Fading
                  </Paper>
                </motion.div>
              </Grid>
              <Grid item xs={12} sm={6} md={3}>
                <Typography variant="h6" gutterBottom>Button Animation</Typography>
                <motion.div whileTap={{ scale: 0.95 }}>
                  <Button
                    variant="contained"
                    color="primary"
                    size="large"
                    fullWidth
                    sx={{ height: 100 }}
                  >
                    Click Me
                  </Button>
                </motion.div>
              </Grid>
            </Grid>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
};
export default StyleGuidePage;
EOF
  log_info "Página de guía de estilo creada correctamente."
}

# Crear configuración Nginx para despliegue
create_deployment_config() {
  log_step "Creando configuración para despliegue..."
  # Configuración de Nginx para Plesk
  cat > nginx.conf << EOF
server {
  listen 80;
  server_name $FRONTEND_DOMAIN;
  # Redireccionar HTTP a HTTPS
  return 301 https://\$host\$request_uri;
}
server {
  listen 443 ssl http2;
  server_name $FRONTEND_DOMAIN;
  # Configuración SSL gestionada por Plesk
  root /var/www/vhosts/$FRONTEND_DOMAIN/httpdocs;
  index index.html;
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
    application/xml
    application/xml+rss
    text/css
    text/javascript
    text/plain
    text/xml;
  # SPA handling
  location / {
    try_files \$uri \$uri/ /index.html;
    add_header Cache-Control "no-cache, no-store, must-revalidate";
  }
  # Proxy para el API - evitar problemas de CORS
  location /api/ {
    proxy_pass $BACKEND_URL/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
  # Caché para activos estáticos
  location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 30d;
    add_header Cache-Control "public, no-transform";
  }
  # Seguridad
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-XSS-Protection "1; mode=block" always;
  add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://js.stripe.com https://cdn.jsdelivr.net; connect-src 'self' https://core.dialoom.com wss://*.agora.io https://api.stripe.com; img-src 'self' data: https://*.dialoom.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; frame-src 'self' https://js.stripe.com;" always;
  # Prohibir acceso a archivos ocultos
  location ~ /\\. {
    deny all;
    access_log off;
    log_not_found off;
  }
}
EOF
  # Script de compilación y despliegue
  cat > deploy.sh << EOF
#!/bin/bash
# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
# Directorio de la aplicación
APP_DIR="$FRONTEND_DIR/$PROJECT_NAME"
SITE_ROOT="$FRONTEND_DIR"
# Función para imprimir mensajes
log_info() {
  echo -e "\${GREEN}[INFO]\${NC} \$1"
}
log_warn() {
  echo -e "\${YELLOW}[WARN]\${NC} \$1"
}
log_error() {
  echo -e "\${RED}[ERROR]\${NC} \$1"
}
# Verificar que estamos en el directorio correcto
if [ ! -f "\$APP_DIR/package.json" ]; then
  log_error "No se encontró package.json. ¿Estás en el directorio correcto?"
  exit 1
fi
# Ir al directorio de la aplicación
cd "\$APP_DIR" || exit 1

log_info "Actualizando dependencias..."
npm install --legacy-peer-deps

log_info "Compilando la aplicación para producción..."
npm run build

if [ \$? -ne 0 ]; then
  log_error "Error durante la compilación"
  exit 1
fi

log_info "Compilación completada con éxito"

# Crear archivo .htaccess para Apache (por si se usa en lugar de Nginx)
cat > dist/.htaccess << 'EOF_HTACCESS'
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
# Establecer cabeceras de seguridad
<IfModule mod_headers.c>
  Header set X-Content-Type-Options "nosniff"
  Header set X-Frame-Options "SAMEORIGIN"
  Header set X-XSS-Protection "1; mode=block"
  Header set Referrer-Policy "strict-origin-when-cross-origin"
  Header set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://js.stripe.com https://cdn.jsdelivr.net; connect-src 'self' https://core.dialoom.com wss://*.agora.io https://api.stripe.com; img-src 'self' data: https://*.dialoom.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; frame-src 'self' https://js.stripe.com;"
  # Caché para activos estáticos
  <FilesMatch "\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
    Header set Cache-Control "max-age=2592000, public"
  </FilesMatch>
  # Sin caché para el HTML
  <FilesMatch "\.(html|htm)$">
    Header set Cache-Control "no-cache, no-store, must-revalidate"
  </FilesMatch>
</IfModule>
EOF_HTACCESS

# Crear archivo web.config para IIS (por si se usa en Windows)
cat > dist/web.config << 'EOF_WEB_CONFIG'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="SPA Routes" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/" />
        </rule>
      </rules>
    </rewrite>
    <httpProtocol>
      <customHeaders>
        <add name="X-Content-Type-Options" value="nosniff" />
        <add name="X-Frame-Options" value="SAMEORIGIN" />
        <add name="X-XSS-Protection" value="1; mode=block" />
        <add name="Referrer-Policy" value="strict-origin-when-cross-origin" />
        <add name="Content-Security-Policy" value="default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://js.stripe.com https://cdn.jsdelivr.net; connect-src 'self' https://core.dialoom.com wss://*.agora.io https://api.stripe.com; img-src 'self' data: https://*.dialoom.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; frame-src 'self' https://js.stripe.com;" />
      </customHeaders>
    </httpProtocol>
    <staticContent>
      <clientCache cacheControlMode="UseMaxAge" cacheControlMaxAge="30.00:00:00" />
    </staticContent>
  </system.webServer>
</configuration>
EOF_WEB_CONFIG

# Crear robots.txt
cat > dist/robots.txt << EOF_ROBOTS
User-agent: *
Allow: /
Sitemap: https://$FRONTEND_DOMAIN/sitemap.xml
EOF_ROBOTS

# Copiar archivo de configuración Nginx si no existe
if [ ! -f "/var/www/vhosts/$FRONTEND_DOMAIN/conf/web/nginx.conf" ]; then
  log_info "Copiando configuración de Nginx..."
  cp "\$APP_DIR/nginx.conf" "/var/www/vhosts/$FRONTEND_DOMAIN/conf/web/nginx.conf"
  # Reiniciar Nginx a través de Plesk
  log_info "Reiniciando Nginx..."
  plesk bin server_pref -u -nginx-restart -value true
else
  log_warn "El archivo de configuración de Nginx ya existe. No se sobrescribirá."
  log_info "Si deseas actualizarlo, cópialo manualmente o elimina el archivo existente."
fi

# Copiar archivos al directorio raíz del sitio
log_info "Copiando archivos al directorio raíz del sitio..."
cp -r dist/* "\$SITE_ROOT/"

log_info "✅ Despliegue completado. La aplicación está disponible en https://$FRONTEND_DOMAIN"
EOF
  # Hacer ejecutable el script de despliegue
  chmod +x deploy.sh
  log_info "Configuración para despliegue creada correctamente."
}

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
