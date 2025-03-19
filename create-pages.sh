#!/bin/bash

# =============================================================================
# DIALOOM FRONTEND - CREADOR DE PÁGINAS FALTANTES
# =============================================================================
# Este script crea los archivos de página faltantes mencionados en App.tsx
# y corrige los errores de compilación
# =============================================================================

# Configuración de colores para los mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorio del proyecto
FRONTEND_DIR="/var/www/vhosts/test.dialoom.com/httpdocs/dialoom-frontend"

# Funciones para mensajes
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Verificar directorio
if [ ! -d "$FRONTEND_DIR" ]; then
  log_error "No se encontró el directorio del proyecto"
  exit 1
fi

cd "$FRONTEND_DIR" || exit 1
log_step "Trabajando en: $FRONTEND_DIR"

# 1. Corregir queryClient.ts
log_step "Corrigiendo queryClient.ts..."
cat > src/api/queryClient.ts << 'EOF'
import { QueryClient } from '@tanstack/react-query'
import { toast } from 'react-toastify'

// Configurar cliente de React Query con opciones optimizadas
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      retryDelay: attemptIndex => Math.min(1000 * 2 ** attemptIndex, 30000),
      staleTime: 5 * 60 * 1000, // 5 minutos
      gcTime: 10 * 60 * 1000, // 10 minutos
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 0,
    },
  },
})

// Función global para manejar errores de peticiones
export const handleQueryError = (error: unknown): unknown => {
  const errorMessage = error instanceof Error 
    ? error.message 
    : 'Error desconocido, por favor intenta nuevamente'
  
  // Solo mostrar toast para errores que no sean 401 (no autorizados)
  if (typeof errorMessage === 'string' && !errorMessage.includes('401')) {
    toast.error(errorMessage)
  }
  
  return error
}
EOF
log_info "queryClient.ts corregido"

# 2. Crear plantilla para archivos de página
create_page() {
  local PAGE_PATH=$1
  local PAGE_NAME=$2
  local PAGE_TITLE=$3
  local IS_ADMIN=${4:-false}
  local HAS_PROPS=${5:-false}
  
  # Crear directorio si no existe
  mkdir -p "$(dirname "$PAGE_PATH")"
  
  # Base común del componente
  local COMPONENT_BASE="import React from 'react'
import { Box, Typography, Paper, Container, Button, Grid } from '@mui/material'
import { useTranslation } from 'react-i18next'"

  # Props y firma de componente
  local COMPONENT_PROPS=""
  local COMPONENT_SIGNATURE=""
  
  if [ "$HAS_PROPS" = "true" ]; then
    COMPONENT_PROPS="interface ${PAGE_NAME}Props {
  isHostView?: boolean
}"
    COMPONENT_SIGNATURE="const $PAGE_NAME: React.FC<${PAGE_NAME}Props> = ({ isHostView }) => {"
  else
    COMPONENT_PROPS="interface ${PAGE_NAME}Props {}"
    COMPONENT_SIGNATURE="const $PAGE_NAME: React.FC<${PAGE_NAME}Props> = () => {"
  fi
  
  # Título y descripción específicos
  local PAGE_DESCRIPTION=""
  if [ "$IS_ADMIN" = "true" ]; then
    PAGE_DESCRIPTION="Módulo de administración para gestionar $PAGE_TITLE"
  else
    PAGE_DESCRIPTION="$PAGE_TITLE en Dialoom"
  fi
  
  # Contenido adicional
  local ADDITIONAL_CONTENT=""
  if [ "$IS_ADMIN" = "true" ]; then
    ADDITIONAL_CONTENT="<Grid container spacing={3} sx={{ mt: 2 }}>
          <Grid item xs={12} md={6} lg={4}>
            <Paper sx={{ p: 3, height: '100%' }}>
              <Typography variant=\"h6\" gutterBottom>
                Estadísticas
              </Typography>
              <Typography variant=\"body2\" color=\"text.secondary\">
                Información estadística sobre $PAGE_TITLE
              </Typography>
            </Paper>
          </Grid>
          <Grid item xs={12} md={6} lg={4}>
            <Paper sx={{ p: 3, height: '100%' }}>
              <Typography variant=\"h6\" gutterBottom>
                Acciones
              </Typography>
              <Box sx={{ mt: 2 }}>
                <Button variant=\"contained\" color=\"primary\" fullWidth>
                  Agregar Nuevo
                </Button>
              </Box>
            </Paper>
          </Grid>
          <Grid item xs={12} md={12} lg={4}>
            <Paper sx={{ p: 3, height: '100%' }}>
              <Typography variant=\"h6\" gutterBottom>
                Reportes
              </Typography>
              <Typography variant=\"body2\" color=\"text.secondary\">
                Generar reportes sobre $PAGE_TITLE
              </Typography>
            </Paper>
          </Grid>
        </Grid>"
  elif [ "$HAS_PROPS" = "true" ]; then
    ADDITIONAL_CONTENT="<Box sx={{ mt: 4 }}>
          {isHostView ? (
            <Paper sx={{ p: 3, mt: 2 }}>
              <Typography variant=\"h6\" gutterBottom>
                Vista de Mentor
              </Typography>
              <Typography variant=\"body2\">
                Estás viendo la perspectiva de mentor para $PAGE_TITLE
              </Typography>
            </Paper>
          ) : (
            <Paper sx={{ p: 3, mt: 2 }}>
              <Typography variant=\"h6\" gutterBottom>
                Vista de Usuario
              </Typography>
              <Typography variant=\"body2\">
                Estás viendo la perspectiva de usuario para $PAGE_TITLE
              </Typography>
            </Paper>
          )}
        </Box>"
  else
    ADDITIONAL_CONTENT="<Box sx={{ mt: 4 }}>
          <Typography variant=\"body2\" color=\"text.secondary\">
            Esta página está en desarrollo.
          </Typography>
          <Button variant=\"contained\" color=\"primary\" sx={{ mt: 2 }}>
            Acción Principal
          </Button>
        </Box>"
  fi
  
  # Generar el archivo completo
  cat > "$PAGE_PATH" << EOF
$COMPONENT_BASE

$COMPONENT_PROPS

$COMPONENT_SIGNATURE
  const { t } = useTranslation()
  
  return (
    <Container maxWidth="lg">
      <Paper 
        elevation={2} 
        sx={{ 
          p: 4, 
          mt: 2, 
          borderRadius: 2, 
          bgcolor: 'background.paper' 
        }}
      >
        <Typography variant="h4" component="h1" gutterBottom>
          $PAGE_TITLE
        </Typography>
        
        <Typography variant="body1" paragraph>
          $PAGE_DESCRIPTION
        </Typography>
        
        $ADDITIONAL_CONTENT
      </Paper>
    </Container>
  )
}

export default $PAGE_NAME
EOF

  log_info "Creado: $PAGE_PATH"
}

# 3. Crear todos los archivos de página mencionados en App.tsx
log_step "Creando archivos de página..."

# Auth pages
create_page "src/features/auth/pages/LoginPage.tsx" "LoginPage" "Iniciar Sesión"
create_page "src/features/auth/pages/RegisterPage.tsx" "RegisterPage" "Registro de Usuario"
create_page "src/features/auth/pages/ForgotPasswordPage.tsx" "ForgotPasswordPage" "Recuperar Contraseña"
create_page "src/features/auth/pages/ResetPasswordPage.tsx" "ResetPasswordPage" "Restablecer Contraseña"

# Dashboard page
create_page "src/features/dashboard/pages/DashboardPage.tsx" "DashboardPage" "Panel de Control" false true

# Hosts pages
create_page "src/features/hosts/pages/HostsListPage.tsx" "HostsListPage" "Listado de Mentores"
create_page "src/features/hosts/pages/HostDetailPage.tsx" "HostDetailPage" "Detalles del Mentor"

# Reservations pages
create_page "src/features/reservations/pages/ReservationsPage.tsx" "ReservationsPage" "Reservas" false true
create_page "src/features/reservations/pages/ReservationDetailPage.tsx" "ReservationDetailPage" "Detalle de Reserva"

# Call page
create_page "src/features/calls/pages/CallPage.tsx" "CallPage" "Videollamada"

# Payments page
create_page "src/features/payments/pages/PaymentsPage.tsx" "PaymentsPage" "Pagos y Transacciones"

# Profile pages
create_page "src/features/profile/pages/ProfilePage.tsx" "ProfilePage" "Perfil de Usuario"
create_page "src/features/profile/pages/SettingsPage.tsx" "SettingsPage" "Configuración"

# Admin pages
create_page "src/features/admin/pages/AdminDashboardPage.tsx" "AdminDashboardPage" "Panel de Administración" true
create_page "src/features/admin/pages/users/AdminUsersPage.tsx" "AdminUsersPage" "Usuarios" true
create_page "src/features/admin/pages/hosts/AdminHostsPage.tsx" "AdminHostsPage" "Mentores" true
create_page "src/features/admin/pages/content/AdminContentPage.tsx" "AdminContentPage" "Contenido" true
create_page "src/features/admin/pages/theme/AdminThemePage.tsx" "AdminThemePage" "Tema y Apariencia" true
create_page "src/features/admin/pages/payments/AdminPaymentsPage.tsx" "AdminPaymentsPage" "Pagos" true
create_page "src/features/admin/pages/achievements/AdminAchievementsPage.tsx" "AdminAchievementsPage" "Logros" true
create_page "src/features/admin/pages/reports/AdminReportsPage.tsx" "AdminReportsPage" "Reportes" true

log_info "Todas las páginas han sido creadas correctamente"

# 4. Compilar y desplegar
log_step "Compilando y desplegando la aplicación..."

npm run build

if [ $? -eq 0 ]; then
  log_info "✅ Compilación exitosa"
  
  # Crear .htaccess y otros archivos de despliegue
  log_step "Creando archivos para despliegue..."
  
  # Crear archivo .htaccess para Apache
  cat > dist/.htaccess << 'EOF_HTACCESS'
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
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

  # Copiar archivo de configuración Nginx si no existe
  if [ ! -f "/var/www/vhosts/test.dialoom.com/conf/web/nginx.conf" ]; then
    log_info "Copiando configuración de Nginx..."
    cp "$FRONTEND_DIR/nginx.conf" "/var/www/vhosts/test.dialoom.com/conf/web/nginx.conf"
    
    # Reiniciar Nginx a través de Plesk
    log_info "Reiniciando Nginx..."
    plesk bin server_pref -u -nginx-restart -value true
  else
    log_warn "El archivo de configuración de Nginx ya existe. No se sobrescribirá."
  fi

  # Copiar archivos al directorio raíz del sitio
  log_info "Copiando archivos al directorio raíz del sitio..."
  cp -r dist/* "/var/www/vhosts/test.dialoom.com/httpdocs/"

  log_info "✅ Despliegue completado. La aplicación está disponible en https://test.dialoom.com"
else
  log_error "❌ Error durante la compilación"
  exit 1
fi