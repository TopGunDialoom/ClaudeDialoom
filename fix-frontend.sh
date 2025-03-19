#!/bin/bash

# Configuración de colores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funciones para mensajes
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Asegurarnos de estar en el directorio correcto
cd /var/www/vhosts/test.dialoom.com/httpdocs/dialoom-frontend || exit 1

log_step "1. Corrigiendo archivos con errores de sintaxis"
find src/features -name "*.tsx" -exec sed -i 's/= (()) =>/= () =>/g' {} \;
find src/features -name "*.tsx" -exec sed -i 's/{ isHostView }{ isHostView }/{ isHostView }/g' {} \;
log_info "Archivos corregidos"

log_step "2. Corrigiendo queryClient.ts"
cat > src/api/queryClient.ts << 'EOF'
import { QueryClient } from '@tanstack/react-query'
import { toast } from 'react-toastify'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      retryDelay: attemptIndex => Math.min(1000 * 2 ** attemptIndex, 30000),
      staleTime: 5 * 60 * 1000,
      gcTime: 10 * 60 * 1000,
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: 0,
    },
  },
})

export const handleApiError = (error: unknown) => {
  const errorMessage = error instanceof Error 
    ? error.message 
    : 'Error desconocido'
  
  if (!errorMessage.includes('401')) {
    toast.error(errorMessage)
  }
  
  return error
}
EOF
log_info "queryClient.ts corregido"

log_step "3. Instalando TypeScript y Vite globalmente"
npm install -g typescript vite
log_info "Paquetes globales instalados"

log_step "4. Compilando TypeScript"
tsc
if [ $? -ne 0 ]; then
  log_error "Error en compilación TypeScript"
  exit 1
fi
log_info "TypeScript compilado correctamente"

log_step "5. Construyendo con Vite"
npx vite build
if [ $? -ne 0 ]; then
  log_error "Error en build de Vite"
  exit 1
fi
log_info "Build completado correctamente"

log_step "6. Deployment"
cp -r dist/* /var/www/vhosts/test.dialoom.com/httpdocs/
log_info "Archivos copiados al directorio web"

log_info "✅ PROCESO COMPLETADO EXITOSAMENTE"