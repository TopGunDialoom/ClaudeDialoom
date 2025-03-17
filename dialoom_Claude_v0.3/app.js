cat > app.js << 'EOF'
// app.js
// Este archivo iniciará nuestra aplicación NestJS directamente desde TypeScript
require('ts-node/register');
require('tsconfig-paths/register');
require('./src/main');
EOF

chmod +x app.js