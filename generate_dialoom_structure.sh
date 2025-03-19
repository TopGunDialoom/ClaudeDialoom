#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones para mensajes
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Variables de configuración
SOURCE_DIR=$(pwd)
OUTPUT_SCRIPT="recreate_dialoom_structure.sh"
EXCLUDE_DIRS=("node_modules" ".git" "dist" "build" "coverage" ".idea" ".vscode" "tmp" "temp")
EXCLUDE_FILES=() # Ya no excluimos archivos de configuración
MAX_FILE_SIZE=10485760 # 10MB en bytes - aumentado para permitir archivos más grandes

# Función para verificar si un directorio debe ser excluido
should_exclude_dir() {
  local dir_name=$(basename "$1")
  for excluded in "${EXCLUDE_DIRS[@]}"; do
    if [[ "$dir_name" == "$excluded" ]]; then
      return 0 # true, should exclude
    fi
  done
  return 1 # false, should not exclude
}

# Función para verificar si un archivo debe ser excluido
should_exclude_file() {
  local file_name=$(basename "$1")
  for excluded in "${EXCLUDE_FILES[@]}"; do
    if [[ "$file_name" == "$excluded" ]]; then
      return 0 # true, should exclude
    fi
  done
  
  # Excluir archivos demasiado grandes
  if [[ -f "$1" ]]; then
    local file_size=$(stat -c %s "$1")
    if (( file_size > MAX_FILE_SIZE )); then
      log_warn "Archivo excluido por tamaño ($file_size bytes): $1"
      return 0 # true, should exclude
    fi
    
    # Verificar si es un archivo binario (excepto para archivos específicos)
    if [[ "$file_name" != "package-lock.json" && "$file_name" != "yarn.lock" ]]; then
      if file "$1" | grep -q "binary"; then
        log_warn "Archivo binario excluido: $1"
        return 0 # true, should exclude
      fi
    fi
  fi
  
  return 1 # false, should not exclude
}

# Función para procesar archivos especiales como .env
process_special_file() {
  local file="$1"
  local file_rel_path="${file#$SOURCE_DIR/}"
  local file_name=$(basename "$file")
  
  # Tratamiento especial para .env y archivos de configuración sensibles
  if [[ "$file_name" == .env* || "$file_name" == "*.conf" ]]; then
    log_info "Procesando archivo de configuración: $file_rel_path"
    echo "# Creando archivo de configuración: $file_rel_path" >> "$OUTPUT_SCRIPT"
    echo "if [ ! -f \"$file_rel_path\" ]; then" >> "$OUTPUT_SCRIPT"
    echo "  cat > \"$file_rel_path\" << 'DIALOOM_EOF'" >> "$OUTPUT_SCRIPT"
    cat "$file" >> "$OUTPUT_SCRIPT"
    echo "DIALOOM_EOF" >> "$OUTPUT_SCRIPT"
    echo "  log_info \"Archivo de configuración creado: $file_rel_path\"" >> "$OUTPUT_SCRIPT"
    echo "else" >> "$OUTPUT_SCRIPT"
    echo "  log_warn \"Archivo de configuración existente no sobrescrito: $file_rel_path\"" >> "$OUTPUT_SCRIPT"
    echo "fi" >> "$OUTPUT_SCRIPT"
    echo "" >> "$OUTPUT_SCRIPT"
    return 0 # Procesado como archivo especial
  fi
  
  return 1 # No es un archivo especial
}

# Función para analizar recursivamente un directorio y generar código para recrearlo
process_directory() {
  local dir="$1"
  local rel_path="${dir#$SOURCE_DIR/}"
  
  if [[ -z "$rel_path" ]]; then
    rel_path="."
  fi
  
  if should_exclude_dir "$dir"; then
    log_warn "Directorio excluido: $dir"
    return
  fi
  
  log_info "Procesando directorio: $rel_path"
  
  # Añadir comando para crear el directorio
  if [[ "$rel_path" != "." ]]; then
    echo "mkdir -p \"$rel_path\"" >> "$OUTPUT_SCRIPT"
  fi
  
  # Procesar todos los archivos en este directorio
  find "$dir" -maxdepth 1 -type f | sort | while read -r file; do
    if should_exclude_file "$file"; then
      continue
    fi
    
    local file_rel_path="${file#$SOURCE_DIR/}"
    log_info "Procesando archivo: $file_rel_path"
    
    # Verificar si es un archivo especial que necesita tratamiento especial
    if process_special_file "$file"; then
      continue
    fi
    
    # Añadir comandos para recrear el archivo
    echo "cat > \"$file_rel_path\" << 'DIALOOM_EOF'" >> "$OUTPUT_SCRIPT"
    cat "$file" >> "$OUTPUT_SCRIPT"
    echo "DIALOOM_EOF" >> "$OUTPUT_SCRIPT"
    echo "" >> "$OUTPUT_SCRIPT"
  done
  
  # Recursivamente procesar subdirectorios
  find "$dir" -mindepth 1 -maxdepth 1 -type d | sort | while read -r subdir; do
    process_directory "$subdir"
  done
}

# Iniciar creación del script
log_step "Iniciando generación de script para recrear estructura completa de Dialoom..."

# Crear script con encabezado
cat > "$OUTPUT_SCRIPT" << 'EOL'
#!/bin/bash

# Script para recrear la estructura completa de directorios y archivos de la API de Dialoom
# Generado automáticamente - Incluye archivos de configuración

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Crear directorio de destino
read -p "Ingrese el directorio donde desea recrear la estructura (default: ./dialoom-api): " TARGET_DIR
TARGET_DIR=${TARGET_DIR:-"./dialoom-api"}

if [ -d "$TARGET_DIR" ]; then
  log_warn "El directorio '$TARGET_DIR' ya existe."
  read -p "¿Desea continuar y sobrescribir archivos existentes? (s/n): " CONTINUE
  if [[ "$CONTINUE" != "s" ]]; then
    log_error "Operación cancelada."
    exit 1
  fi
else
  mkdir -p "$TARGET_DIR"
fi

cd "$TARGET_DIR" || exit 1
log_step "Comenzando a recrear la estructura completa en: $(pwd)"

# Inicio de la recreación de la estructura
EOL

# Asegurarse de que el script es ejecutable
chmod +x "$OUTPUT_SCRIPT"

# Procesar el directorio raíz y todos sus contenidos
process_directory "$SOURCE_DIR"

# Agregar comandos finales al script
cat >> "$OUTPUT_SCRIPT" << 'EOL'

# Hacer ejecutables los scripts
find . -name "*.sh" -exec chmod +x {} \;

log_step "Estructura recreada correctamente"
log_info "Se han recreado todos los archivos incluyendo configuraciones"

log_step "Instalación de dependencias"
read -p "¿Desea instalar las dependencias ahora (requiere Node.js y npm)? (s/n): " INSTALL_DEPS

if [[ "$INSTALL_DEPS" == "s" ]]; then
  log_info "Instalando dependencias..."
  if [ -f "package.json" ]; then
    npm install
    if [ $? -eq 0 ]; then
      log_info "Dependencias instaladas correctamente."
    else
      log_error "Error al instalar dependencias. Verifique los mensajes de error."
    fi
  else
    log_warn "No se encontró package.json. No se pueden instalar dependencias."
  fi
fi

log_info "Estructura de Dialoom recreada exitosamente en: $(pwd)"
log_info "La aplicación está lista para ser configurada y ejecutada."
EOL

# Hacer ejecutable el script generado
chmod +x "$OUTPUT_SCRIPT"

log_info "Script generado exitosamente: $OUTPUT_SCRIPT"
log_info "Este script recreará la estructura completa de la API Dialoom, incluyendo todos los archivos de configuración."
log_info "Ejecute: bash $OUTPUT_SCRIPT para recrear la estructura."
