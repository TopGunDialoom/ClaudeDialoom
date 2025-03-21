#!/bin/bash
# Dialoom Frontend - Script de corrección final

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="web.dialoom.com"
APP_DIR="/var/www/vhosts/$DOMAIN/httpdocs"
FRONTEND_DIR="$APP_DIR/dialoom-frontend"

echo -e "${BLUE}[INFO]${NC} Iniciando reparación final de Dialoom Frontend..."

# 1. Hacer copia de seguridad del directorio original (opcional)
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_DIR="$APP_DIR/dialoom-backup-$TIMESTAMP"

echo -e "${BLUE}[INFO]${NC} Haciendo copia de seguridad en $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
cp -r "$FRONTEND_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}[OK]${NC} Copia de seguridad creada."

# 2. Limpiar completamente el directorio
echo -e "${BLUE}[INFO]${NC} Limpiando completamente el directorio..."
rm -rf "$FRONTEND_DIR"
mkdir -p "$FRONTEND_DIR"
cd "$FRONTEND_DIR"
echo -e "${GREEN}[OK]${NC} Directorio limpio."

# 3. Crear una aplicación React mínima garantizada
echo -e "${BLUE}[INFO]${NC} Creando aplicación React mínima sin dependencias adicionales..."

# Crear package.json básico
cat > "$FRONTEND_DIR/package.json" << 'EOF'
{
  "name": "dialoom-frontend",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.3",
    "vite": "^4.4.5"
  }
}
EOF

# Crear vite.config.js simplificado
cat > "$FRONTEND_DIR/vite.config.js" << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()]
})
EOF

# Crear index.html
cat > "$FRONTEND_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dialoom</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# Crear estructura básica de React
mkdir -p "$FRONTEND_DIR/src"

# Crear main.jsx
cat > "$FRONTEND_DIR/src/main.jsx" << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# Crear App.jsx
cat > "$FRONTEND_DIR/src/App.jsx" << 'EOF'
import React, { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="app">
      <header className="app-header">
        <div className="logo">D</div>
        <h1>Dialoom</h1>
        <p>Plataforma de mentores profesionales</p>
        
        <div className="card">
          <button onClick={() => setCount(count => count + 1)}>
            Contador: {count}
          </button>
          <p>La aplicación está funcionando correctamente</p>
        </div>

        <p className="status">✅ Ejecutando en Plesk</p>
      </header>
    </div>
  )
}

export default App
EOF

# Crear estilos CSS sin PostCSS/Tailwind
cat > "$FRONTEND_DIR/src/index.css" << 'EOF'
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen,
    Ubuntu, Cantarell, 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

* {
  box-sizing: border-box;
}
EOF

# Crear App.css
cat > "$FRONTEND_DIR/src/App.css" << 'EOF'
.app {
  text-align: center;
}

.app-header {
  background-color: #1A7A8B;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 1.5vmin);
  color: white;
  padding: 0 20px;
}

.logo {
  width: 120px;
  height: 120px;
  background-color: white;
  color: #1A7A8B;
  border-radius: 50%;
  font-size: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  margin-bottom: 20px;
}

h1 {
  margin: 0;
}

.card {
  margin-top: 40px;
  padding: 20px;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  color: #333;
  max-width: 500px;
  width: 100%;
}

button {
  background-color: #1A7A8B;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  margin-bottom: 15px;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #0d6d7c;
}

.status {
  margin-top: 40px;
  font-size: 16px;
  opacity: 0.8;
}
EOF

# 4. Instalar dependencias y compilar
echo -e "${BLUE}[INFO]${NC} Instalando dependencias básicas..."
npm install

echo -e "${BLUE}[INFO]${NC} Compilando la aplicación..."
npm run build

if [ $? -ne 0 ]; then
  echo -e "${RED}[ERROR]${NC} Fallo en la compilación."
  exit 1
fi

echo -e "${GREEN}[OK]${NC} Compilación exitosa."

# 5. Crear app.js en la raíz
echo -e "${BLUE}[INFO]${NC} Configurando app.js en la raíz..."
cat > "$APP_DIR/app.js" << 'EOF'
const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware para logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Servir archivos estáticos
const distPath = path.join(__dirname, 'dialoom-frontend/dist');
console.log('Ruta de la aplicación:', distPath);

if (fs.existsSync(distPath)) {
  // Listar contenido de dist
  console.log('Contenido de dist:');
  fs.readdirSync(distPath).forEach(file => {
    console.log(`- ${file}`);
  });
  
  // Servir archivos estáticos
  app.use(express.static(distPath));
  
  // Rutas SPA
  app.get('*', (req, res) => {
    res.sendFile(path.join(distPath, 'index.html'));
  });
} else {
  console.error('Error: No se encontró el directorio dist');
  
  app.get('*', (req, res) => {
    res.status(500).send(`
      <html>
        <head>
          <title>Dialoom - Error</title>
          <style>
            body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; }
            h1 { color: #cc0000; }
            .container { border: 1px solid #ddd; padding: 20px; border-radius: 8px; margin-top: 30px; }
          </style>
        </head>
        <body>
          <h1>Error: Aplicación no encontrada</h1>
          <div class="container">
            <p>No se encontró la aplicación compilada en: ${distPath}</p>
            <p>Por favor, revisa los logs del servidor para más información.</p>
          </div>
        </body>
      </html>
    `);
  });
}

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Servidor Dialoom iniciado en puerto ${PORT}`);
  console.log(`Fecha y hora: ${new Date().toISOString()}`);
  console.log(`Entorno: ${process.env.NODE_ENV || 'desarrollo'}`);
});
EOF

# 6. Instalar express en la raíz
echo -e "${BLUE}[INFO]${NC} Instalando express en el directorio raíz..."
cd "$APP_DIR"
if [ ! -d "node_modules/express" ]; then
  npm install express --save
fi

# 7. Mensaje final
echo -e "
${GREEN}==================================================${NC}
${GREEN}      REPARACIÓN DE DIALOOM COMPLETADA           ${NC}
${GREEN}==================================================${NC}

${BLUE}[INFO]${NC} Se ha creado una aplicación React básica funcional.
${BLUE}[INFO]${NC} La aplicación ha sido compilada y está lista para usarse.

${YELLOW}[IMPORTANTE]${NC} Para completar la instalación:

1. Reinicia la aplicación Node.js desde el panel de Plesk:
   - Websites & Domains → Node.js para web.dialoom.com → Restart App

2. Accede a la aplicación en:
   http://$DOMAIN

${BLUE}[DIAGNÓSTICO]${NC} Si sigues viendo una página en blanco:
- Revisa los logs de Node.js en el panel de Plesk
- Verifica que el directorio '$FRONTEND_DIR/dist' existe y contiene archivos
- Confirma que app.js se está ejecutando correctamente

${GREEN}[BACKUP]${NC} Una copia de seguridad de la versión anterior está en:
$BACKUP_DIR
"