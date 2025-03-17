#!/usr/bin/env bash

#
# export.sh
# Script para generar la estructura completa del backend de Dialoom con NestJS
#
# Uso:
#   chmod +x export.sh
#   ./export.sh
#
# Resultado:
#   Crea la carpeta ./dialoom-backend y todos los archivos necesarios
#

echo "=== Creando estructura de Dialoom Backend (NestJS) ==="

# Crear directorio principal y moverse a él
mkdir -p dialoom-backend
cd dialoom-backend

# Crear estructura base de directorios
mkdir -p src/{config,common/{decorators,filters,guards,interceptors,pipes},modules} \
         test \
         locales

# Crear estructura de módulos
mkdir -p src/modules/{auth/{strategies,guards,dto},users/{entities,dto},hosts/{entities,dto},reservations/{entities,dto},payments/{entities,dto},calls/{entities,dto},notifications/{channels,entities,dto},gamification/{entities,dto},admin/{entities,dto},i18n}

# Archivos de configuración raíz
cat << 'EOF' > .env.example
# Base de datos
DB_HOST=localhost
DB_PORT=3306
DB_USER=ubuntu
DB_PASS=paczug-beGkov-0syvci
DB_NAME=coreadmin

# JWT
JWT_SECRET=your_jwt_secret_key_change_in_production
JWT_EXPIRES_IN=3600

# Stripe
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Agora
AGORA_APP_ID=your_agora_app_id
AGORA_APP_CERTIFICATE=your_agora_certificate

# SendGrid
SENDGRID_API_KEY=your_sendgrid_api_key
SENDGRID_FROM_EMAIL=noreply@dialoom.com

# OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_CALLBACK_URL=http://localhost:3000/auth/google/callback

FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret
FACEBOOK_CALLBACK_URL=http://localhost:3000/auth/facebook/callback

APPLE_CLIENT_ID=your_apple_client_id
APPLE_TEAM_ID=your_apple_team_id
APPLE_KEY_ID=your_apple_key_id
APPLE_PRIVATE_KEY=your_apple_private_key

# App
PORT=3000
NODE_ENV=development

# Retención y comisión
RETENTION_DAYS=7
COMMISSION_RATE=0.10
VAT_RATE=0.21
EOF

cat << 'EOF' > .gitignore
# compiled output
/dist
/node_modules

# Logs
logs
*.log
npm-debug.log*
pnpm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# OS
.DS_Store

# Tests
/coverage
/.nyc_output

# IDEs and editors
/.idea
.project
.classpath
.c9/
*.launch
.settings/
*.sublime-workspace
.vscode/*

# dotenv environment variables file
.env
.env.test
.env.production

# package lock files
package-lock.json
yarn.lock
EOF

cat << 'EOF' > .prettierrc
{
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "semi": true
}
EOF

cat << 'EOF' > tsconfig.json
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "es2017",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": false,
    "noImplicitAny": false,
    "strictBindCallApply": false,
    "forceConsistentCasingInFileNames": false,
    "noFallthroughCasesInSwitch": false,
    "paths": {
      "@/*": ["src/*"],
      "@config/*": ["src/config/*"],
      "@common/*": ["src/common/*"],
      "@modules/*": ["src/modules/*"]
    }
  }
}
EOF

cat << 'EOF' > nest-cli.json
{
  "collection": "@nestjs/schematics",
  "sourceRoot": "src",
  "compilerOptions": {
    "deleteOutDir": true,
    "assets": [
      {
        "include": "**/*.{json,html,css}",
        "outDir": "dist"
      },
      {
        "include": "../locales/**/*",
        "outDir": "dist/locales"
      }
    ],
    "watchAssets": true
  }
}
EOF

cat << 'EOF' > package.json
{
  "name": "dialoom-backend",
  "version": "0.1.0",
  "description": "Dialoom Backend API with NestJS",
  "author": "Dialoom Team",
  "private": true,
  "license": "UNLICENSED",
  "scripts": {
    "prebuild": "rimraf dist",
    "build": "nest build",
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/main",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register node_modules/.bin/jest --runInBand",
    "test:e2e": "jest --config ./test/jest-e2e.json"
  },
  "dependencies": {
    "@nestjs/common": "^9.4.0",
    "@nestjs/config": "^2.3.1",
    "@nestjs/core": "^9.4.0",
    "@nestjs/jwt": "^10.0.3",
    "@nestjs/passport": "^9.0.3",
    "@nestjs/platform-express": "^9.4.0",
    "@nestjs/swagger": "^6.3.0",
    "@nestjs/typeorm": "^9.0.1",
    "@sendgrid/mail": "^7.7.0",
    "agora-access-token": "^2.0.4",
    "bcrypt": "^5.1.0",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.0",
    "cookie-parser": "^1.4.6",
    "date-fns": "^2.29.3",
    "helmet": "^6.1.5",
    "i18n": "^0.15.1",
    "mysql2": "^3.2.4",
    "passport": "^0.6.0",
    "passport-apple": "^2.0.2",
    "passport-facebook": "^3.0.0",
    "passport-google-oauth20": "^2.0.0",
    "passport-jwt": "^4.0.1",
    "passport-local": "^1.0.0",
    "reflect-metadata": "^0.1.13",
    "rimraf": "^5.0.0",
    "rxjs": "^7.8.1",
    "speakeasy": "^2.0.0",
    "stripe": "^12.3.0",
    "typeorm": "^0.3.15",
    "uuid": "^9.0.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^9.4.2",
    "@nestjs/schematics": "^9.1.0",
    "@nestjs/testing": "^9.4.0",
    "@types/bcrypt": "^5.0.0",
    "@types/cookie-parser": "^1.4.3",
    "@types/express": "^4.17.17",
    "@types/jest": "^29.5.1",
    "@types/node": "^18.16.3",
    "@types/passport-jwt": "^3.0.8",
    "@types/passport-local": "^1.0.35",
    "@types/speakeasy": "^2.0.7",
    "@types/supertest": "^2.0.12",
    "@types/uuid": "^9.0.1",
    "@typescript-eslint/eslint-plugin": "^5.59.2",
    "@typescript-eslint/parser": "^5.59.2",
    "eslint": "^8.39.0",
    "eslint-config-prettier": "^8.8.0",
    "eslint-plugin-prettier": "^4.2.1",
    "jest": "^29.5.0",
    "prettier": "^2.8.8",
    "source-map-support": "^0.5.21",
    "supertest": "^6.3.3",
    "ts-jest": "^29.1.0",
    "ts-loader": "^9.4.2",
    "ts-node": "^10.9.1",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.0.4"
  },
  "jest": {
    "moduleFileExtensions": [
      "js",
      "json",
      "ts"
    ],
    "rootDir": "src",
    "testRegex": ".*\\.spec\\.ts$",
    "transform": {
      "^.+\\.(t|j)s$": "ts-jest"
    },
    "collectCoverageFrom": [
      "**/*.(t|j)s"
    ],
    "coverageDirectory": "../coverage",
    "testEnvironment": "node",
    "moduleNameMapper": {
      "^@/(.*)$": "<rootDir>/$1",
      "^@config/(.*)$": "<rootDir>/config/$1",
      "^@common/(.*)$": "<rootDir>/common/$1",
      "^@modules/(.*)$": "<rootDir>/modules/$1"
    }
  }
}
EOF

cat << 'EOF' > Dockerfile
FROM node:18-alpine As development

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM node:18-alpine As production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --only=production

COPY . .

COPY --from=development /usr/src/app/dist ./dist

CMD ["node", "dist/main"]
EOF

cat << 'EOF' > docker-compose.yml
version: '3.8'

services:
  api:
    build:
      context: .
      target: development
    volumes:
      - .:/usr/src/app
      - /usr/src/app/node_modules
    ports:
      - "${PORT:-3000}:3000"
    command: npm run start:dev
    env_file:
      - .env
    restart: unless-stopped
    networks:
      - dialoom-network

networks:
  dialoom-network:
    driver: bridge
EOF

# Crear archivos principales
cat << 'EOF' > src/main.ts
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import * as cookieParser from 'cookie-parser';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);
  const port = configService.get<number>('PORT', 3000);

  // Seguridad
  app.use(helmet());
  app.use(cookieParser());
  app.enableCors({
    origin: true,
    credentials: true,
  });

  // Validación
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Prefijo global para la API
  app.setGlobalPrefix('api');

  // Swagger para documentación
  const config = new DocumentBuilder()
    .setTitle('Dialoom API')
    .setDescription('API Documentation for Dialoom Backend')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap();
EOF

cat << 'EOF' > src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { APP_FILTER, APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';

import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import { JwtAuthGuard } from './modules/auth/guards/jwt-auth.guard';

import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { HostsModule } from './modules/hosts/hosts.module';
import { ReservationsModule } from './modules/reservations/reservations.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { CallsModule } from './modules/calls/calls.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { GamificationModule } from './modules/gamification/gamification.module';
import { AdminModule } from './modules/admin/admin.module';
import { I18nModule } from './modules/i18n/i18n.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'mysql',
        host: configService.get('DB_HOST', 'localhost'),
        port: configService.get<number>('DB_PORT', 3306),
        username: configService.get('DB_USER', 'ubuntu'),
        password: configService.get('DB_PASS', 'paczug-beGkov-0syvci'),
        database: configService.get('DB_NAME', 'coreadmin'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: configService.get('NODE_ENV') !== 'production', // Sólo para desarrollo
        logging: configService.get('NODE_ENV') !== 'production',
      }),
    }),
    AuthModule,
    UsersModule,
    HostsModule,
    ReservationsModule,
    PaymentsModule,
    CallsModule,
    NotificationsModule,
    GamificationModule,
    AdminModule,
    I18nModule,
  ],
  providers: [
    {
      provide: APP_FILTER,
      useClass: AllExceptionsFilter,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: LoggingInterceptor,
    },
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
EOF

# Crear archivos comunes
cat << 'EOF' > src/common/filters/all-exceptions.filter.ts
import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.getResponse()
        : 'Internal server error';

    // Log the exception
    this.logger.error(
      `Exception: ${request.method} ${request.url}`,
      exception instanceof Error ? exception.stack : 'Unknown error',
    );

    // Return a standardized error response
    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message,
    });
  }
}
EOF

cat << 'EOF' > src/common/interceptors/logging.interceptor.ts
import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    const { method, url, body, user } = req;
    
    const userId = user ? user.id : 'anonymous';
    const userInfo = user ? `user ${userId}` : 'anonymous user';
    
    this.logger.log(`[${method}] ${url} - Request by ${userInfo}`);
    
    const now = Date.now();
    return next.handle().pipe(
      tap(() => {
        const response = context.switchToHttp().getResponse();
        const delay = Date.now() - now;
        this.logger.log(
          `[${method}] ${url} - Response status ${response.statusCode} - ${delay}ms`,
        );
      }),
    );
  }
}
EOF

cat << 'EOF' > src/common/decorators/roles.decorator.ts
import { SetMetadata } from '@nestjs/common';
import { UserRole } from '../../modules/users/entities/user.entity';

export const ROLES_KEY = 'roles';
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
EOF

cat << 'EOF' > src/common/guards/roles.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { UserRole } from '../../modules/users/entities/user.entity';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    
    if (!requiredRoles) {
      return true;
    }
    
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.role === role);
  }
}
EOF

cat << 'EOF' > src/common/guards/public.guard.ts
import { ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';

export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => (target, key, descriptor) => {
  Reflector.defineMetadata(IS_PUBLIC_KEY, true, descriptor.value);
  return descriptor;
};

@Injectable()
export class PublicGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    
    if (isPublic) {
      return true;
    }
    
    return super.canActivate(context);
  }
}
EOF

# Crear archivos de configuración
cat << 'EOF' > src/config/database.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('database', () => ({
  type: 'mysql',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT, 10) || 3306,
  username: process.env.DB_USER || 'ubuntu',
  password: process.env.DB_PASS || 'paczug-beGkov-0syvci',
  database: process.env.DB_NAME || 'coreadmin',
  synchronize: process.env.NODE_ENV !== 'production',
  logging: process.env.NODE_ENV !== 'production',
}));
EOF

cat << 'EOF' > src/config/jwt.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('jwt', () => ({
  secret: process.env.JWT_SECRET || 'secretKey',
  expiresIn: process.env.JWT_EXPIRES_IN || '1h',
}));
EOF

cat << 'EOF' > src/config/stripe.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('stripe', () => ({
  secretKey: process.env.STRIPE_SECRET_KEY || '',
  webhookSecret: process.env.STRIPE_WEBHOOK_SECRET || '',
  commissionRate: parseFloat(process.env.COMMISSION_RATE) || 0.10,
  vatRate: parseFloat(process.env.VAT_RATE) || 0.21,
  retentionDays: parseInt(process.env.RETENTION_DAYS, 10) || 7,
}));
EOF

cat << 'EOF' > src/config/agora.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('agora', () => ({
  appId: process.env.AGORA_APP_ID || '',
  appCertificate: process.env.AGORA_APP_CERTIFICATE || '',
}));
EOF

cat << 'EOF' > src/config/sendgrid.config.ts
import { registerAs } from '@nestjs/config';

export default registerAs('sendgrid', () => ({
  apiKey: process.env.SENDGRID_API_KEY || '',
  fromEmail: process.env.SENDGRID_FROM_EMAIL || 'noreply@dialoom.com',
}));
EOF

# Crear módulos
# Módulo de Users
cat << 'EOF' > src/modules/users/entities/user.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Exclude } from 'class-transformer';

export enum UserRole {
  USER = 'user',
  HOST = 'host',
  ADMIN = 'admin',
  SUPERADMIN = 'superadmin',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  firstName: string;

  @Column({ length: 100 })
  lastName: string;

  @Column({ unique: true })
  email: string;

  @Column({ nullable: true })
  @Exclude()
  password: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.USER,
  })
  role: UserRole;

  @Column({ default: false })
  isVerified: boolean;

  @Column({ default: false })
  isBanned: boolean;

  @Column({ default: false })
  twoFactorEnabled: boolean;

  @Column({ nullable: true })
  @Exclude()
  twoFactorSecret: string;

  @Column({ nullable: true })
  profileImage: string;

  @Column({ nullable: true })
  phoneNumber: string;

  @Column({ default: 'es' })
  preferredLanguage: string;

  @Column({ default: 0 })
  points: number;

  @Column({ default: 1 })
  level: number;

  @Column({ nullable: true })
  stripeCustomerId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations will be added here as needed
}
EOF

cat << 'EOF' > src/modules/users/users.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
EOF

cat << 'EOF' > src/modules/users/users.service.ts
import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findAll(): Promise<User[]> {
    return this.usersRepository.find();
  }

  async findById(id: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async findByEmail(email: string): Promise<User> {
    return this.usersRepository.findOne({ where: { email } });
  }

  async create(userData: Partial<User>): Promise<User> {
    const existingUser = await this.findByEmail(userData.email);
    if (existingUser) {
      throw new ConflictException(`User with email ${userData.email} already exists`);
    }

    if (userData.password) {
      userData.password = await this.hashPassword(userData.password);
    }

    const newUser = this.usersRepository.create(userData);
    return this.usersRepository.save(newUser);
  }

  async update(id: string, userData: Partial<User>): Promise<User> {
    await this.findById(id); // Check if user exists

    if (userData.password) {
      userData.password = await this.hashPassword(userData.password);
    }

    await this.usersRepository.update(id, userData);
    return this.findById(id);
  }

  async delete(id: string): Promise<void> {
    const user = await this.findById(id);
    await this.usersRepository.remove(user);
  }

  async updateRole(id: string, role: UserRole): Promise<User> {
    const user = await this.findById(id);
    user.role = role;
    return this.usersRepository.save(user);
  }

  async verifyUser(id: string): Promise<User> {
    const user = await this.findById(id);
    user.isVerified = true;
    return this.usersRepository.save(user);
  }

  async banUser(id: string): Promise<User> {
    const user = await this.findById(id);
    user.isBanned = true;
    return this.usersRepository.save(user);
  }

  async unbanUser(id: string): Promise<User> {
    const user = await this.findById(id);
    user.isBanned = false;
    return this.usersRepository.save(user);
  }

  async updatePoints(id: string, points: number): Promise<User> {
    const user = await this.findById(id);
    user.points += points;
    return this.usersRepository.save(user);
  }

  private async hashPassword(password: string): Promise<string> {
    const saltRounds = 10;
    return bcrypt.hash(password, saltRounds);
  }
}
EOF

cat << 'EOF' > src/modules/users/users.controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { User, UserRole } from './entities/user.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@ApiTags('users')
@Controller('users')
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Get all users' })
  findAll(): Promise<User[]> {
    return this.usersService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  findOne(@Param('id') id: string): Promise<User> {
    return this.usersService.findById(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new user' })
  create(@Body() userData: Partial<User>): Promise<User> {
    return this.usersService.create(userData);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a user' })
  update(@Param('id') id: string, @Body() userData: Partial<User>): Promise<User> {
    return this.usersService.update(id, userData);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Delete a user' })
  remove(@Param('id') id: string): Promise<void> {
    return this.usersService.delete(id);
  }

  @Put(':id/verify')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Verify a user' })
  verifyUser(@Param('id') id: string): Promise<User> {
    return this.usersService.verifyUser(id);
  }

  @Put(':id/ban')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Ban a user' })
  banUser(@Param('id') id: string): Promise<User> {
    return this.usersService.banUser(id);
  }

  @Put(':id/unban')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Unban a user' })
  unbanUser(@Param('id') id: string): Promise<User> {
    return this.usersService.unbanUser(id);
  }

  @Put(':id/role')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Update user role' })
  updateRole(
    @Param('id') id: string,
    @Body('role') role: UserRole,
  ): Promise<User> {
    return this.usersService.updateRole(id, role);
  }
}
EOF

# Módulo de Auth
cat << 'EOF' > src/modules/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UsersModule } from '../users/users.module';
import { JwtStrategy } from './strategies/jwt.strategy';
import { LocalStrategy } from './strategies/local.strategy';
import { GoogleStrategy } from './strategies/google.strategy';
import { FacebookStrategy } from './strategies/facebook.strategy';
import { AppleStrategy } from './strategies/apple.strategy';

@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<string>('JWT_EXPIRES_IN', '1h'),
        },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
    LocalStrategy,
    GoogleStrategy,
    FacebookStrategy,
    AppleStrategy,
  ],
  exports: [AuthService],
})
export class AuthModule {}
EOF

cat << 'EOF' > src/modules/auth/auth.service.ts
import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import * as speakeasy from 'speakeasy';
import { UsersService } from '../users/users.service';
import { User, UserRole } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async validateUser(email: string, password: string): Promise<User> {
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (user.isBanned) {
      throw new UnauthorizedException('Your account has been banned');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return user;
  }

  async login(user: User, twoFactorCode?: string) {
    if (user.twoFactorEnabled) {
      if (!twoFactorCode) {
        return { requiresTwoFactor: true };
      }

      const isCodeValid = this.verifyTwoFactorCode(user, twoFactorCode);
      if (!isCodeValid) {
        throw new UnauthorizedException('Invalid two-factor code');
      }
    }

    return {
      accessToken: this.generateToken(user),
      user: this.sanitizeUser(user),
    };
  }

  async registerUser(userData: {
    firstName: string;
    lastName: string;
    email: string;
    password: string;
  }): Promise<User> {
    return this.usersService.create({
      ...userData,
      role: UserRole.USER,
    });
  }

  async validateOAuthUser(profile: any, provider: string): Promise<User> {
    const email = profile.emails?.[0]?.value;
    if (!email) {
      throw new BadRequestException('Email not provided by OAuth provider');
    }

    let user = await this.usersService.findByEmail(email);
    if (user) {
      return user;
    }

    // Create new user from OAuth data
    const firstName = profile.name?.givenName || profile.displayName.split(' ')[0];
    const lastName = profile.name?.familyName || profile.displayName.split(' ').slice(1).join(' ');

    return this.usersService.create({
      firstName,
      lastName,
      email,
      role: UserRole.USER,
      isVerified: true, // OAuth users are considered verified
    });
  }

  generateToken(user: User): string {
    const payload = {
      email: user.email,
      sub: user.id,
      role: user.role,
    };
    return this.jwtService.sign(payload);
  }

  async generateTwoFactorSecret(): Promise<{
    secret: string;
    otpAuthUrl: string;
  }> {
    const secret = speakeasy.generateSecret({
      name: `Dialoom:${this.configService.get('APP_NAME', 'Dialoom')}`,
    });

    return {
      secret: secret.base32,
      otpAuthUrl: secret.otpauth_url,
    };
  }

  verifyTwoFactorCode(user: User, twoFactorCode: string): boolean {
    return speakeasy.totp.verify({
      secret: user.twoFactorSecret,
      encoding: 'base32',
      token: twoFactorCode,
    });
  }

  async enableTwoFactor(userId: string, secret: string): Promise<User> {
    return this.usersService.update(userId, {
      twoFactorEnabled: true,
      twoFactorSecret: secret,
    });
  }

  async disableTwoFactor(userId: string): Promise<User> {
    return this.usersService.update(userId, {
      twoFactorEnabled: false,
      twoFactorSecret: null,
    });
  }

  // Remove sensitive data from user object
  sanitizeUser(user: User): Partial<User> {
    const { password, twoFactorSecret, ...result } = user;
    return result;
  }
}
EOF

cat << 'EOF' > src/modules/auth/auth.controller.ts
import {
  Controller,
  Post,
  Body,
  UseGuards,
  Get,
  Req,
  Put,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { GoogleAuthGuard } from './guards/google-auth.guard';
import { FacebookAuthGuard } from './guards/facebook-auth.guard';
import { AppleAuthGuard } from './guards/apple-auth.guard';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { Public } from '../../common/guards/public.guard';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @UseGuards(LocalAuthGuard)
  @Post('login')
  @ApiOperation({ summary: 'Login with email and password' })
  async login(
    @Req() req,
    @Body('twoFactorCode') twoFactorCode?: string,
  ) {
    return this.authService.login(req.user, twoFactorCode);
  }

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Register a new user' })
  async register(
    @Body() registerData: {
      firstName: string;
      lastName: string;
      email: string;
      password: string;
    },
  ) {
    const user = await this.authService.registerUser(registerData);
    return this.authService.login(user);
  }

  @Public()
  @Get('google')
  @UseGuards(GoogleAuthGuard)
  @ApiOperation({ summary: 'Login with Google' })
  googleAuth() {
    // This route will redirect to Google
  }

  @Public()
  @Get('google/callback')
  @UseGuards(GoogleAuthGuard)
  googleAuthCallback(@Req() req) {
    return this.authService.login(req.user);
  }

  @Public()
  @Get('facebook')
  @UseGuards(FacebookAuthGuard)
  @ApiOperation({ summary: 'Login with Facebook' })
  facebookAuth() {
    // This route will redirect to Facebook
  }

  @Public()
  @Get('facebook/callback')
  @UseGuards(FacebookAuthGuard)
  facebookAuthCallback(@Req() req) {
    return this.authService.login(req.user);
  }

  @Public()
  @Get('apple')
  @UseGuards(AppleAuthGuard)
  @ApiOperation({ summary: 'Login with Apple' })
  appleAuth() {
    // This route will redirect to Apple
  }

  @Public()
  @Get('apple/callback')
  @UseGuards(AppleAuthGuard)
  appleAuthCallback(@Req() req) {
    return this.authService.login(req.user);
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  getProfile(@Req() req) {
    return this.authService.sanitizeUser(req.user);
  }

  @UseGuards(JwtAuthGuard)
  @Post('2fa/generate')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Generate 2FA secret' })
  async generateTwoFactorSecret() {
    return this.authService.generateTwoFactorSecret();
  }

  @UseGuards(JwtAuthGuard)
  @Post('2fa/enable')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Enable 2FA' })
  async enableTwoFactor(
    @Req() req,
    @Body('secret') secret: string,
    @Body('code') code: string,
  ) {
    const isCodeValid = this.authService.verifyTwoFactorCode(
      { ...req.user, twoFactorSecret: secret },
      code,
    );

    if (!isCodeValid) {
      throw new Error('Invalid verification code');
    }

    await this.authService.enableTwoFactor(req.user.id, secret);
    return { success: true };
  }

  @UseGuards(JwtAuthGuard)
  @Put('2fa/disable')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Disable 2FA' })
  async disableTwoFactor(@Req() req) {
    await this.authService.disableTwoFactor(req.user.id);
    return { success: true };
  }
}
EOF

cat << 'EOF' > src/modules/auth/strategies/jwt.strategy.ts
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UsersService } from '../../users/users.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private configService: ConfigService,
    private usersService: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
    });
  }

  async validate(payload: any) {
    return this.usersService.findById(payload.sub);
  }
}
EOF

cat << 'EOF' > src/modules/auth/strategies/local.strategy.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-local';
import { AuthService } from '../auth.service';

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
  constructor(private authService: AuthService) {
    super({ usernameField: 'email' });
  }

  async validate(email: string, password: string) {
    const user = await this.authService.validateUser(email, password);
    if (!user) {
      throw new UnauthorizedException();
    }
    return user;
  }
}
EOF

cat << 'EOF' > src/modules/auth/strategies/google.strategy.ts
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback } from 'passport-google-oauth20';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    super({
      clientID: configService.get<string>('GOOGLE_CLIENT_ID'),
      clientSecret: configService.get<string>('GOOGLE_CLIENT_SECRET'),
      callbackURL: configService.get<string>('GOOGLE_CALLBACK_URL'),
      scope: ['email', 'profile'],
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: any,
    done: VerifyCallback,
  ) {
    try {
      const user = await this.authService.validateOAuthUser(profile, 'google');
      done(null, user);
    } catch (error) {
      done(error, null);
    }
  }
}
EOF

cat << 'EOF' > src/modules/auth/strategies/facebook.strategy.ts
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-facebook';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';

@Injectable()
export class FacebookStrategy extends PassportStrategy(Strategy, 'facebook') {
  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    super({
      clientID: configService.get<string>('FACEBOOK_APP_ID'),
      clientSecret: configService.get<string>('FACEBOOK_APP_SECRET'),
      callbackURL: configService.get<string>('FACEBOOK_CALLBACK_URL'),
      scope: ['email', 'public_profile'],
      profileFields: ['id', 'emails', 'name', 'displayName'],
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    profile: any,
    done: Function,
  ) {
    try {
      const user = await this.authService.validateOAuthUser(profile, 'facebook');
      done(null, user);
    } catch (error) {
      done(error, null);
    }
  }
}
EOF

cat << 'EOF' > src/modules/auth/strategies/apple.strategy.ts
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-apple';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';

@Injectable()
export class AppleStrategy extends PassportStrategy(Strategy, 'apple') {
  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    super({
      clientID: configService.get<string>('APPLE_CLIENT_ID'),
      teamID: configService.get<string>('APPLE_TEAM_ID'),
      keyID: configService.get<string>('APPLE_KEY_ID'),
      privateKeyString: configService.get<string>('APPLE_PRIVATE_KEY'),
      callbackURL: configService.get<string>('APPLE_CALLBACK_URL'),
      scope: ['email', 'name'],
    });
  }

  async validate(
    accessToken: string,
    refreshToken: string,
    idToken: any,
    profile: any,
    done: Function,
  ) {
    try {
      // Apple doesn't provide profile info in the same way as other providers
      // We need to extract it from the tokens
      const profileData = {
        id: idToken.sub,
        emails: [{ value: idToken.email }],
        displayName: profile.name?.firstName
          ? `${profile.name.firstName} ${profile.name.lastName || ''}`
          : 'Apple User',
        name: profile.name,
      };

      const user = await this.authService.validateOAuthUser(profileData, 'apple');
      done(null, user);
    } catch (error) {
      done(error, null);
    }
  }
}
EOF

cat << 'EOF' > src/modules/auth/guards/jwt-auth.guard.ts
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
EOF

cat << 'EOF' > src/modules/auth/guards/local-auth.guard.ts
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class LocalAuthGuard extends AuthGuard('local') {}
EOF

cat << 'EOF' > src/modules/auth/guards/google-auth.guard.ts
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class GoogleAuthGuard extends AuthGuard('google') {}
EOF

cat << 'EOF' > src/modules/auth/guards/facebook-auth.guard.ts
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class FacebookAuthGuard extends AuthGuard('facebook') {}
EOF

cat << 'EOF' > src/modules/auth/guards/apple-auth.guard.ts
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class AppleAuthGuard extends AuthGuard('apple') {}
EOF

# Crear un módulo básico para Hosts
cat << 'EOF' > src/modules/hosts/entities/host.entity.ts
import {
  Entity,
  PrimaryColumn,
  Column,
  OneToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('hosts')
export class Host {
  @PrimaryColumn()
  userId: string;

  @OneToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'text', nullable: true })
  bio: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  hourlyRate: number;

  @Column({ default: false })
  isVerified: boolean;

  @Column({ default: false })
  isFeatured: boolean;

  @Column({ nullable: true })
  stripeConnectId: string;

  @Column({ nullable: true })
  profileImage: string;

  @Column({ nullable: true })
  bannerImage: string;

  @Column('simple-array', { nullable: true })
  specialties: string[];

  @Column('simple-array', { nullable: true })
  languages: string[];

  @Column({ type: 'int', default: 0 })
  totalSessions: number;

  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
  averageRating: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations will be added here as needed
}
EOF

cat << 'EOF' > src/modules/hosts/hosts.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Host } from './entities/host.entity';
import { HostsService } from './hosts.service';
import { HostsController } from './hosts.controller';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Host]),
    UsersModule,
  ],
  controllers: [HostsController],
  providers: [HostsService],
  exports: [HostsService],
})
export class HostsModule {}
EOF

cat << 'EOF' > src/modules/hosts/hosts.service.ts
import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Host } from './entities/host.entity';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/entities/user.entity';

@Injectable()
export class HostsService {
  constructor(
    @InjectRepository(Host)
    private hostsRepository: Repository<Host>,
    private usersService: UsersService,
  ) {}

  async findAll(featured: boolean = null): Promise<Host[]> {
    const query = this.hostsRepository.createQueryBuilder('host')
      .leftJoinAndSelect('host.user', 'user')
      .where('user.isBanned = :isBanned', { isBanned: false });
    
    if (featured !== null) {
      query.andWhere('host.isFeatured = :featured', { featured });
    }
    
    return query.getMany();
  }

  async findById(id: string): Promise<Host> {
    const host = await this.hostsRepository.findOne({
      where: { userId: id },
      relations: ['user'],
    });
    
    if (!host) {
      throw new NotFoundException(`Host with ID ${id} not found`);
    }
    
    return host;
  }

  async create(userId: string, hostData: Partial<Host>): Promise<Host> {
    // Check if user exists and is not already a host
    const user = await this.usersService.findById(userId);
    
    const existingHost = await this.hostsRepository.findOne({
      where: { userId },
    });
    
    if (existingHost) {
      throw new ConflictException(`User ${userId} is already a host`);
    }
    
    // Update user role to HOST
    await this.usersService.updateRole(userId, UserRole.HOST);
    
    // Create new host profile
    const newHost = this.hostsRepository.create({
      userId,
      ...hostData,
    });
    
    return this.hostsRepository.save(newHost);
  }

  async update(id: string, hostData: Partial<Host>): Promise<Host> {
    await this.findById(id); // Check if host exists
    
    await this.hostsRepository.update({ userId: id }, hostData);
    return this.findById(id);
  }

  async verify(id: string): Promise<Host> {
    const host = await this.findById(id);
    host.isVerified = true;
    return this.hostsRepository.save(host);
  }

  async setFeatured(id: string, featured: boolean): Promise<Host> {
    const host = await this.findById(id);
    host.isFeatured = featured;
    return this.hostsRepository.save(host);
  }

  async updateRating(id: string, rating: number): Promise<Host> {
    const host = await this.findById(id);
    
    // Calculate new average rating
    const totalSessions = host.totalSessions + 1;
    const currentTotalRating = host.averageRating * host.totalSessions;
    const newAverageRating = (currentTotalRating + rating) / totalSessions;
    
    // Update host
    host.totalSessions = totalSessions;
    host.averageRating = Number(newAverageRating.toFixed(2));
    
    return this.hostsRepository.save(host);
  }

  async delete(id: string): Promise<void> {
    const host = await this.findById(id);
    
    // Change user role back to USER
    await this.usersService.updateRole(host.userId, UserRole.USER);
    
    // Delete host profile
    await this.hostsRepository.remove(host);
  }
}
EOF

cat << 'EOF' > src/modules/hosts/hosts.controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { HostsService } from './hosts.service';
import { Host } from './entities/host.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('hosts')
@Controller('hosts')
@ApiBearerAuth()
export class HostsController {
  constructor(private readonly hostsService: HostsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all hosts' })
  @ApiQuery({ name: 'featured', required: false, type: Boolean })
  findAll(@Query('featured') featured?: boolean): Promise<Host[]> {
    return this.hostsService.findAll(featured ? featured === true : null);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get host by ID' })
  findOne(@Param('id') id: string): Promise<Host> {
    return this.hostsService.findById(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new host profile for user' })
  create(
    @Body('userId') userId: string,
    @Body() hostData: Partial<Host>,
  ): Promise<Host> {
    return this.hostsService.create(userId, hostData);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a host profile' })
  update(
    @Param('id') id: string,
    @Body() hostData: Partial<Host>,
  ): Promise<Host> {
    return this.hostsService.update(id, hostData);
  }

  @Put(':id/verify')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Verify a host' })
  verify(@Param('id') id: string): Promise<Host> {
    return this.hostsService.verify(id);
  }

  @Put(':id/featured')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Set featured status for a host' })
  setFeatured(
    @Param('id') id: string,
    @Body('featured') featured: boolean,
  ): Promise<Host> {
    return this.hostsService.setFeatured(id, featured);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Delete a host profile' })
  remove(@Param('id') id: string): Promise<void> {
    return this.hostsService.delete(id);
  }
}
EOF

# Crear un módulo básico para Payments (integración con Stripe)
cat << 'EOF' > src/modules/payments/entities/transaction.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum TransactionStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  REFUNDED = 'refunded',
}

export enum TransactionType {
  PAYMENT = 'payment',
  PAYOUT = 'payout',
  REFUND = 'refund',
}

@Entity('transactions')
export class Transaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'enum', enum: TransactionType })
  type: TransactionType;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ nullable: true })
  hostId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'hostId' })
  host: User;

  @Column({ nullable: true })
  reservationId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  commissionAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  vatAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  netAmount: number;

  @Column({ default: 'EUR' })
  currency: string;

  @Column({ type: 'enum', enum: TransactionStatus, default: TransactionStatus.PENDING })
  status: TransactionStatus;

  @Column({ nullable: true })
  stripePaymentIntentId: string;

  @Column({ nullable: true })
  stripeChargeId: string;

  @Column({ nullable: true })
  stripeTransferId: string;

  @Column({ type: 'boolean', default: false })
  isReleased: boolean;

  @Column({ nullable: true })
  releasedAt: Date;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

cat << 'EOF' > src/modules/payments/payments.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Transaction } from './entities/transaction.entity';
import { PaymentsService } from './payments.service';
import { StripeService } from './stripe.service';
import { PaymentsController } from './payments.controller';
import { UsersModule } from '../users/users.module';
import { HostsModule } from '../hosts/hosts.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Transaction]),
    UsersModule,
    HostsModule,
  ],
  controllers: [PaymentsController],
  providers: [PaymentsService, StripeService],
  exports: [PaymentsService, StripeService],
})
export class PaymentsModule {}
EOF

cat << 'EOF' > src/modules/payments/stripe.service.ts
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';

@Injectable()
export class StripeService {
  private stripe: Stripe;

  constructor(private configService: ConfigService) {
    this.stripe = new Stripe(this.configService.get<string>('STRIPE_SECRET_KEY'), {
      apiVersion: '2022-11-15',
    });
  }

  async createCustomer(email: string, name: string): Promise<string> {
    const customer = await this.stripe.customers.create({
      email,
      name,
    });
    return customer.id;
  }

  async createConnectAccount(email: string, country: string = 'ES'): Promise<string> {
    const account = await this.stripe.accounts.create({
      type: 'express',
      country,
      email,
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
    });
    return account.id;
  }

  async getAccountLinkUrl(accountId: string, refreshUrl: string, returnUrl: string): Promise<string> {
    const accountLink = await this.stripe.accountLinks.create({
      account: accountId,
      refresh_url: refreshUrl,
      return_url: returnUrl,
      type: 'account_onboarding',
    });
    return accountLink.url;
  }

  async createPaymentIntent(
    amount: number,
    currency: string,
    customerId: string,
    hostConnectId: string,
    description: string,
    applicationFeeAmount: number,
  ): Promise<Stripe.PaymentIntent> {
    return this.stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Stripe works with cents
      currency,
      customer: customerId,
      description,
      transfer_data: {
        destination: hostConnectId,
      },
      application_fee_amount: Math.round(applicationFeeAmount * 100),
    });
  }

  async createTransfer(
    amount: number,
    currency: string,
    destinationAccount: string,
    description: string,
  ): Promise<Stripe.Transfer> {
    return this.stripe.transfers.create({
      amount: Math.round(amount * 100),
      currency,
      destination: destinationAccount,
      description,
    });
  }

  async refundPayment(paymentIntentId: string): Promise<Stripe.Refund> {
    return this.stripe.refunds.create({
      payment_intent: paymentIntentId,
    });
  }

  async getPaymentIntent(paymentIntentId: string): Promise<Stripe.PaymentIntent> {
    return this.stripe.paymentIntents.retrieve(paymentIntentId);
  }

  async getAccount(accountId: string): Promise<Stripe.Account> {
    return this.stripe.accounts.retrieve(accountId);
  }

  async constructWebhookEvent(payload: Buffer, signature: string): Promise<Stripe.Event> {
    const webhookSecret = this.configService.get<string>('STRIPE_WEBHOOK_SECRET');
    return this.stripe.webhooks.constructEvent(
      payload,
      signature,
      webhookSecret,
    );
  }
}
EOF

cat << 'EOF' > src/modules/payments/payments.service.ts
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, IsNull } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Transaction, TransactionStatus, TransactionType } from './entities/transaction.entity';
import { StripeService } from './stripe.service';
import { UsersService } from '../users/users.service';
import { HostsService } from '../hosts/hosts.service';
import { addDays } from 'date-fns';

@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Transaction)
    private transactionsRepository: Repository<Transaction>,
    private stripeService: StripeService,
    private usersService: UsersService,
    private hostsService: HostsService,
    private configService: ConfigService,
  ) {}

  async findAll(): Promise<Transaction[]> {
    return this.transactionsRepository.find({
      relations: ['user', 'host'],
    });
  }

  async findById(id: string): Promise<Transaction> {
    const transaction = await this.transactionsRepository.findOne({
      where: { id },
      relations: ['user', 'host'],
    });
    
    if (!transaction) {
      throw new NotFoundException(`Transaction with ID ${id} not found`);
    }
    
    return transaction;
  }

  async findByUser(userId: string): Promise<Transaction[]> {
    return this.transactionsRepository.find({
      where: [
        { userId },
        { hostId: userId },
      ],
      relations: ['user', 'host'],
    });
  }

  async createPaymentIntent(
    userId: string,
    hostId: string,
    amount: number,
    reservationId: string,
    description: string,
  ): Promise<any> {
    const user = await this.usersService.findById(userId);
    const host = await this.hostsService.findById(hostId);
    
    if (!user.stripeCustomerId) {
      const customerId = await this.stripeService.createCustomer(
        user.email,
        `${user.firstName} ${user.lastName}`,
      );
      await this.usersService.update(userId, { stripeCustomerId: customerId });
      user.stripeCustomerId = customerId;
    }
    
    if (!host.stripeConnectId) {
      throw new BadRequestException('Host Stripe account not set up');
    }
    
    // Calculate commission and VAT
    const commissionRate = this.configService.get<number>('stripe.commissionRate', 0.10);
    const vatRate = this.configService.get<number>('stripe.vatRate', 0.21);
    
    const commissionAmount = amount * commissionRate;
    const vatAmount = commissionAmount * vatRate;
    const applicationFeeAmount = commissionAmount + vatAmount;
    const netAmount = amount - applicationFeeAmount;
    
    // Create Stripe PaymentIntent
    const paymentIntent = await this.stripeService.createPaymentIntent(
      amount,
      'EUR',
      user.stripeCustomerId,
      host.stripeConnectId,
      description,
      applicationFeeAmount,
    );
    
    // Create transaction record
    const transaction = this.transactionsRepository.create({
      type: TransactionType.PAYMENT,
      userId,
      hostId,
      reservationId,
      amount,
      commissionAmount,
      vatAmount,
      netAmount,
      status: TransactionStatus.PENDING,
      stripePaymentIntentId: paymentIntent.id,
    });
    
    await this.transactionsRepository.save(transaction);
    
    return {
      clientSecret: paymentIntent.client_secret,
      transactionId: transaction.id,
    };
  }

  async handlePaymentIntentSucceeded(paymentIntentId: string): Promise<Transaction> {
    const transaction = await this.transactionsRepository.findOne({
      where: { stripePaymentIntentId: paymentIntentId },
    });
    
    if (!transaction) {
      throw new NotFoundException(`Transaction with payment intent ${paymentIntentId} not found`);
    }
    
    const paymentIntent = await this.stripeService.getPaymentIntent(paymentIntentId);
    
    transaction.status = TransactionStatus.COMPLETED;
    if (paymentIntent.charges.data.length > 0) {
      transaction.stripeChargeId = paymentIntent.charges.data[0].id;
    }
    
    return this.transactionsRepository.save(transaction);
  }

  async processReleasePendingPayments(): Promise<Transaction[]> {
    const retentionDays = this.configService.get<number>('stripe.retentionDays', 7);
    const retentionDate = addDays(new Date(), -retentionDays);
    
    const pendingTransactions = await this.transactionsRepository.find({
      where: {
        status: TransactionStatus.COMPLETED,
        isReleased: false,
        createdAt: LessThanOrEqual(retentionDate),
      },
    });
    
    const releasedTransactions: Transaction[] = [];
    
    for (const transaction of pendingTransactions) {
      transaction.isReleased = true;
      transaction.releasedAt = new Date();
      
      await this.transactionsRepository.save(transaction);
      
      releasedTransactions.push(transaction);
    }
    
    return releasedTransactions;
  }

  async refundTransaction(transactionId: string, reason: string): Promise<Transaction> {
    const transaction = await this.findById(transactionId);
    
    if (transaction.status !== TransactionStatus.COMPLETED) {
      throw new BadRequestException('Only completed transactions can be refunded');
    }
    
    if (!transaction.stripePaymentIntentId) {
      throw new BadRequestException('Transaction has no associated payment intent');
    }
    
    const refund = await this.stripeService.refundPayment(transaction.stripePaymentIntentId);
    
    transaction.status = TransactionStatus.REFUNDED;
    transaction.notes = reason;
    
    return this.transactionsRepository.save(transaction);
  }

  async getTransactionStats() {
    const totalTransactions = await this.transactionsRepository.count({
      where: { status: TransactionStatus.COMPLETED },
    });
    
    const result = await this.transactionsRepository
      .createQueryBuilder('transaction')
      .select('SUM(transaction.amount)', 'totalAmount')
      .addSelect('SUM(transaction.commissionAmount)', 'totalCommission')
      .addSelect('SUM(transaction.vatAmount)', 'totalVat')
      .where('transaction.status = :status', { status: TransactionStatus.COMPLETED })
      .getRawOne();
    
    return {
      totalTransactions,
      totalAmount: result.totalAmount || 0,
      totalCommission: result.totalCommission || 0,
      totalVat: result.totalVat || 0,
      totalRevenue: (result.totalCommission || 0) + (result.totalVat || 0),
    };
  }
}
EOF

cat << 'EOF' > src/modules/payments/payments.controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  UseGuards,
  Req,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { StripeService } from './stripe.service';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';
import { Public } from '../../common/guards/public.guard';

@ApiTags('payments')
@Controller('payments')
@ApiBearerAuth()
export class PaymentsController {
  constructor(
    private readonly paymentsService: PaymentsService,
    private readonly stripeService: StripeService,
  ) {}

  @Get()
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Get all transactions (admin only)' })
  findAll() {
    return this.paymentsService.findAll();
  }

  @Get('me')
  @ApiOperation({ summary: 'Get current user transactions' })
  findUserTransactions(@Req() req) {
    return this.paymentsService.findByUser(req.user.id);
  }

  @Get('stats')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Get payment statistics (admin only)' })
  getStats() {
    return this.paymentsService.getTransactionStats();
  }

  @Post('create-intent')
  @ApiOperation({ summary: 'Create a payment intent' })
  createPaymentIntent(
    @Req() req,
    @Body() paymentData: {
      hostId: string;
      amount: number;
      reservationId: string;
      description: string;
    },
  ) {
    return this.paymentsService.createPaymentIntent(
      req.user.id,
      paymentData.hostId,
      paymentData.amount,
      paymentData.reservationId,
      paymentData.description,
    );
  }

  @Post('create-connect-account')
  @ApiOperation({ summary: 'Create a Stripe Connect account for a host' })
  async createConnectAccount(
    @Req() req,
    @Body() data: { 
      country?: string;
      refreshUrl: string;
      returnUrl: string;
    },
  ) {
    const accountId = await this.stripeService.createConnectAccount(
      req.user.email,
      data.country || 'ES',
    );
    
    const accountLinkUrl = await this.stripeService.getAccountLinkUrl(
      accountId,
      data.refreshUrl,
      data.returnUrl,
    );
    
    return { accountId, accountLinkUrl };
  }

  @Post('refund/:id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Refund a transaction (admin only)' })
  refundTransaction(
    @Param('id') id: string,
    @Body('reason') reason: string,
  ) {
    return this.paymentsService.refundTransaction(id, reason);
  }

  @Post('process-releases')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Process pending payments to be released (admin only)' })
  processReleases() {
    return this.paymentsService.processReleasePendingPayments();
  }

  @Public()
  @Post('webhook')
  @ApiOperation({ summary: 'Stripe webhook handler' })
  async handleWebhook(@Req() request) {
    const sig = request.headers['stripe-signature'];
    
    try {
      const event = await this.stripeService.constructWebhookEvent(
        request.rawBody,
        sig,
      );
      
      switch (event.type) {
        case 'payment_intent.succeeded':
          const paymentIntent = event.data.object;
          await this.paymentsService.handlePaymentIntentSucceeded(paymentIntent.id);
          break;
        // Handle other events as needed
      }
      
      return { received: true };
    } catch (err) {
      console.error('Webhook error:', err.message);
      throw err;
    }
  }
}
EOF

# Crear un módulo básico para Calls (integración con Agora)
cat << 'EOF' > src/modules/calls/calls.module.ts
import { Module } from '@nestjs/common';
import { CallsService } from './calls.service';
import { CallsController } from './calls.controller';
import { ReservationsModule } from '../reservations/reservations.module';

@Module({
  imports: [ReservationsModule],
  controllers: [CallsController],
  providers: [CallsService],
  exports: [CallsService],
})
export class CallsModule {}
EOF

cat << 'EOF' > src/modules/calls/calls.service.ts
import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { RtcTokenBuilder, RtcRole } from 'agora-access-token';
import { ReservationsService } from '../reservations/reservations.service';

@Injectable()
export class CallsService {
  constructor(
    private configService: ConfigService,
    private reservationsService: ReservationsService,
  ) {}

  async generateToken(
    reservationId: string,
    userId: string,
    role: 'host' | 'client',
  ): Promise<{ token: string; channelName: string; uid: number; appId: string }> {
    const reservation = await this.reservationsService.findById(reservationId);
    
    if (!reservation) {
      throw new NotFoundException('Reservation not found');
    }
    
    // Check if user is part of the reservation
    const isParticipant =
      userId === reservation.userId || userId === reservation.hostId;
    
    if (!isParticipant) {
      throw new BadRequestException('User is not part of this reservation');
    }
    
    // Check if it's time for the call
    const now = new Date();
    const sessionStart = new Date(reservation.startTime);
    const sessionEnd = new Date(reservation.endTime);
    
    // Allow joining 10 minutes before the session
    const earlyJoinWindow = new Date(sessionStart);
    earlyJoinWindow.setMinutes(earlyJoinWindow.getMinutes() - 10);
    
    if (now < earlyJoinWindow && userId !== reservation.hostId) {
      throw new BadRequestException('Too early to join this call');
    }
    
    if (now > sessionEnd) {
      throw new BadRequestException('This session has already ended');
    }
    
    // Create a unique channel name based on the reservation ID
    const channelName = `dialoom-session-${reservationId}`;
    
    // Generate a UID for the user (could be stored in a real application)
    const uid = role === 'host'
      ? parseInt(reservation.hostId.replace(/\D/g, '').slice(-6), 10) % 100000
      : parseInt(reservation.userId.replace(/\D/g, '').slice(-6), 10) % 100000;
    
    // Get Agora credentials from config
    const appId = this.configService.get<string>('AGORA_APP_ID');
    const appCertificate = this.configService.get<string>('AGORA_APP_CERTIFICATE');
    
    if (!appId || !appCertificate) {
      throw new BadRequestException('Agora credentials not configured');
    }
    
    // Set token expiration (2 hours from now)
    const expirationTimeInSeconds = 7200;
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
    
    // Build token
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      uid,
      role === 'host' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER,
      privilegeExpiredTs,
    );
    
    return {
      token,
      channelName,
      uid,
      appId,
    };
  }
}
EOF

cat << 'EOF' > src/modules/calls/calls.controller.ts
import {
  Controller,
  Get,
  Query,
  UseGuards,
  Req,
  BadRequestException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CallsService } from './calls.service';

@ApiTags('calls')
@Controller('calls')
@ApiBearerAuth()
export class CallsController {
  constructor(private readonly callsService: CallsService) {}

  @Get('token')
  @ApiOperation({ summary: 'Generate Agora token for a call' })
  async generateToken(
    @Req() req,
    @Query('reservationId') reservationId: string,
    @Query('role') role: 'host' | 'client',
  ) {
    if (!role || !['host', 'client'].includes(role)) {
      throw new BadRequestException('Invalid role. Must be "host" or "client"');
    }
    
    if (!reservationId) {
      throw new BadRequestException('reservationId is required');
    }
    
    return this.callsService.generateToken(
      reservationId,
      req.user.id,
      role,
    );
  }
}
EOF

# Crear un módulo básico para Reservations
cat << 'EOF' > src/modules/reservations/entities/reservation.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum ReservationStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  CANCELLED = 'cancelled',
  COMPLETED = 'completed',
  NO_SHOW = 'no_show',
}

@Entity('reservations')
export class Reservation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  hostId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'hostId' })
  host: User;

  @Column({ type: 'timestamp' })
  startTime: Date;

  @Column({ type: 'timestamp' })
  endTime: Date;

  @Column({ type: 'enum', enum: ReservationStatus, default: ReservationStatus.PENDING })
  status: ReservationStatus;

  @Column({ nullable: true })
  transactionId: string;

  @Column({ nullable: true })
  cancellationReason: string;

  @Column({ nullable: true })
  notes: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ default: false })
  isRescheduled: boolean;

  @Column({ nullable: true })
  originalReservationId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

cat << 'EOF' > src/modules/reservations/entities/availability.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum RecurrenceType {
  ONCE = 'once',
  DAILY = 'daily',
  WEEKLY = 'weekly',
}

@Entity('availabilities')
export class Availability {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  hostId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'hostId' })
  host: User;

  @Column({ type: 'timestamp' })
  startTime: Date;

  @Column({ type: 'timestamp' })
  endTime: Date;

  @Column({ type: 'enum', enum: RecurrenceType, default: RecurrenceType.ONCE })
  recurrenceType: RecurrenceType;

  @Column({ type: 'simple-array', nullable: true })
  daysOfWe
  ek: string[];

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

cat << 'EOF' > src/modules/reservations/reservations.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Reservation } from './entities/reservation.entity';
import { Availability } from './entities/availability.entity';
import { ReservationsService } from './reservations.service';
import { ReservationsController } from './reservations.controller';
import { UsersModule } from '../users/users.module';
import { HostsModule } from '../hosts/hosts.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Reservation, Availability]),
    UsersModule,
    HostsModule,
  ],
  controllers: [ReservationsController],
  providers: [ReservationsService],
  exports: [ReservationsService],
})
export class ReservationsModule {}
EOF

cat << 'EOF' > src/modules/reservations/reservations.service.ts
import { 
  Injectable, 
  NotFoundException, 
  BadRequestException, 
  ConflictException 
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { Reservation, ReservationStatus } from './entities/reservation.entity';
import { Availability, RecurrenceType } from './entities/availability.entity';
import { UsersService } from '../users/users.service';
import { HostsService } from '../hosts/hosts.service';
import { addDays, isAfter, isBefore } from 'date-fns';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class ReservationsService {
  constructor(
    @InjectRepository(Reservation)
    private reservationsRepository: Repository<Reservation>,
    @InjectRepository(Availability)
    private availabilityRepository: Repository<Availability>,
    private usersService: UsersService,
    private hostsService: HostsService,
  ) {}

  async findAll(): Promise<Reservation[]> {
    return this.reservationsRepository.find({
      relations: ['user', 'host'],
    });
  }

  async findById(id: string): Promise<Reservation> {
    const reservation = await this.reservationsRepository.findOne({
      where: { id },
      relations: ['user', 'host'],
    });
    
    if (!reservation) {
      throw new NotFoundException(`Reservation with ID ${id} not found`);
    }
    
    return reservation;
  }

  async findByUser(userId: string): Promise<Reservation[]> {
    return this.reservationsRepository.find({
      where: { userId },
      relations: ['host'],
      order: { startTime: 'DESC' },
    });
  }

  async findByHost(hostId: string): Promise<Reservation[]> {
    return this.reservationsRepository.find({
      where: { hostId },
      relations: ['user'],
      order: { startTime: 'DESC' },
    });
  }

  async findUpcoming(userId: string, isHost: boolean = false): Promise<Reservation[]> {
    const now = new Date();
    
    return this.reservationsRepository.find({
      where: {
        [isHost ? 'hostId' : 'userId']: userId,
        startTime: MoreThanOrEqual(now),
        status: ReservationStatus.CONFIRMED,
      },
      relations: isHost ? ['user'] : ['host'],
      order: { startTime: 'ASC' },
    });
  }

  async create(
    userId: string,
    hostId: string,
    startTime: Date,
    endTime: Date,
    amount: number,
  ): Promise<Reservation> {
    // Validate input
    if (isBefore(startTime, new Date())) {
      throw new BadRequestException('Start time must be in the future');
    }
    
    if (!isAfter(endTime, startTime)) {
      throw new BadRequestException('End time must be after start time');
    }
    
    // Check if the host is available
    const isAvailable = await this.checkHostAvailability(
      hostId,
      startTime,
      endTime,
    );
    
    if (!isAvailable) {
      throw new BadRequestException('Host is not available for the selected time slot');
    }
    
    // Check if user and host exist
    await this.usersService.findById(userId);
    await this.hostsService.findById(hostId);
    
    // Create the reservation
    const reservation = this.reservationsRepository.create({
      id: uuidv4(),
      userId,
      hostId,
      startTime,
      endTime,
      status: ReservationStatus.PENDING,
      amount,
    });
    
    return this.reservationsRepository.save(reservation);
  }

  async updateStatus(
    id: string,
    status: ReservationStatus,
    reason?: string,
  ): Promise<Reservation> {
    const reservation = await this.findById(id);
    
    reservation.status = status;
    
    if (reason) {
      if (status === ReservationStatus.CANCELLED) {
        reservation.cancellationReason = reason;
      } else {
        reservation.notes = reason;
      }
    }
    
    return this.reservationsRepository.save(reservation);
  }

  async cancel(id: string, userId: string, reason: string): Promise<Reservation> {
    const reservation = await this.findById(id);
    
    // Check if the user is part of the reservation
    if (reservation.userId !== userId && reservation.hostId !== userId) {
      throw new BadRequestException('You are not allowed to cancel this reservation');
    }
    
    // Check if the reservation can be cancelled
    if (reservation.status !== ReservationStatus.PENDING && 
        reservation.status !== ReservationStatus.CONFIRMED) {
      throw new BadRequestException('This reservation cannot be cancelled');
    }
    
    // Check cancellation window (e.g., 24 hours before)
    const now = new Date();
    const cancellationDeadline = new Date(reservation.startTime);
    cancellationDeadline.setHours(cancellationDeadline.getHours() - 24);
    
    if (isAfter(now, cancellationDeadline)) {
      throw new BadRequestException('Cancellation deadline has passed');
    }
    
    // Update reservation status
    reservation.status = ReservationStatus.CANCELLED;
    reservation.cancellationReason = reason;
    
    return this.reservationsRepository.save(reservation);
  }

  async reschedule(
    id: string,
    userId: string,
    newStartTime: Date,
    newEndTime: Date,
  ): Promise<Reservation> {
    const originalReservation = await this.findById(id);
    
    // Check if the user is part of the reservation
    if (originalReservation.userId !== userId && originalReservation.hostId !== userId) {
      throw new BadRequestException('You are not allowed to reschedule this reservation');
    }
    
    // Check if the reservation can be rescheduled
    if (originalReservation.status !== ReservationStatus.CONFIRMED) {
      throw new BadRequestException('This reservation cannot be rescheduled');
    }
    
    // Check if the new time slot is available
    const isAvailable = await this.checkHostAvailability(
      originalReservation.hostId,
      newStartTime,
      newEndTime,
    );
    
    if (!isAvailable) {
      throw new BadRequestException('Host is not available for the new time slot');
    }
    
    // Create a new reservation
    const newReservation = this.reservationsRepository.create({
      id: uuidv4(),
      userId: originalReservation.userId,
      hostId: originalReservation.hostId,
      startTime: newStartTime,
      endTime: newEndTime,
      status: ReservationStatus.CONFIRMED,
      amount: originalReservation.amount,
      isRescheduled: true,
      originalReservationId: originalReservation.id,
      transactionId: originalReservation.transactionId,
    });
    
    // Cancel the original reservation
    originalReservation.status = ReservationStatus.CANCELLED;
    originalReservation.cancellationReason = 'Rescheduled';
    
    await this.reservationsRepository.save(originalReservation);
    return this.reservationsRepository.save(newReservation);
  }

  async complete(id: string): Promise<Reservation> {
    const reservation = await this.findById(id);
    
    if (reservation.status !== ReservationStatus.CONFIRMED) {
      throw new BadRequestException('This reservation cannot be marked as completed');
    }
    
    // Check if the reservation time has passed
    const now = new Date();
    if (isBefore(now, reservation.endTime)) {
      throw new BadRequestException('This reservation has not ended yet');
    }
    
    reservation.status = ReservationStatus.COMPLETED;
    return this.reservationsRepository.save(reservation);
  }

  // Host availability management
  async createAvailability(
    hostId: string,
    startTime: Date,
    endTime: Date,
    recurrenceType: RecurrenceType = RecurrenceType.ONCE,
    daysOfWeek?: string[],
  ): Promise<Availability> {
    // Validate input
    if (!isAfter(endTime, startTime)) {
      throw new BadRequestException('End time must be after start time');
    }
    
    if (recurrenceType !== RecurrenceType.ONCE && !daysOfWeek?.length) {
      throw new BadRequestException('Days of week must be provided for recurring availability');
    }
    
    // Check if host exists
    await this.hostsService.findById(hostId);
    
    // Create availability
    const availability = this.availabilityRepository.create({
      hostId,
      startTime,
      endTime,
      recurrenceType,
      daysOfWeek,
    });
    
    return this.availabilityRepository.save(availability);
  }

  async getHostAvailability(hostId: string, startDate: Date, endDate: Date): Promise<Availability[]> {
    // Fetch all active availabilities for this host
    const availabilities = await this.availabilityRepository.find({
      where: {
        hostId,
        isActive: true,
      },
    });
    
    // Filter by date range and expand recurring availabilities
    const result: Availability[] = [];
    
    for (const availability of availabilities) {
      if (availability.recurrenceType === RecurrenceType.ONCE) {
        // Check if one-time availability is within the requested range
        if (
          (isAfter(availability.startTime, startDate) || availability.startTime.getTime() === startDate.getTime()) &&
          (isBefore(availability.endTime, endDate) || availability.endTime.getTime() === endDate.getTime())
        ) {
          result.push(availability);
        }
      } else {
        // Handle recurring availabilities by creating instances for each occurrence
        // This is a simplified implementation
        const currentDate = new Date(startDate);
        
        while (isBefore(currentDate, endDate)) {
          const dayOfWeek = currentDate.getDay().toString();
          
          if (availability.daysOfWeek.includes(dayOfWeek)) {
            // Create an instance for this day
            const instanceStart = new Date(currentDate);
            instanceStart.setHours(
              availability.startTime.getHours(),
              availability.startTime.getMinutes(),
            );
            
            const instanceEnd = new Date(currentDate);
            instanceEnd.setHours(
              availability.endTime.getHours(),
              availability.endTime.getMinutes(),
            );
            
            result.push({
              ...availability,
              startTime: instanceStart,
              endTime: instanceEnd,
            });
          }
          
          // Move to next day
          currentDate.setDate(currentDate.getDate() + 1);
        }
      }
    }
    
    return result;
  }

  async checkHostAvailability(hostId: string, startTime: Date, endTime: Date): Promise<boolean> {
    // Get host availabilities
    const availabilities = await this.getHostAvailability(
      hostId,
      new Date(startTime.getFullYear(), startTime.getMonth(), startTime.getDate()),
      new Date(endTime.getFullYear(), endTime.getMonth(), endTime.getDate() + 1),
    );
    
    // Check if there's an availability that fully contains the requested time slot
    const hasAvailability = availabilities.some(
      (a) =>
        (isBefore(a.startTime, startTime) || a.startTime.getTime() === startTime.getTime()) &&
        (isAfter(a.endTime, endTime) || a.endTime.getTime() === endTime.getTime()),
    );
    
    if (!hasAvailability) {
      return false;
    }
    
    // Check if there are no overlapping confirmed reservations
    const overlappingReservations = await this.reservationsRepository.find({
      where: {
        hostId,
        status: ReservationStatus.CONFIRMED,
        startTime: LessThanOrEqual(endTime),
        endTime: MoreThanOrEqual(startTime),
      },
    });
    
    return overlappingReservations.length === 0;
  }
}
EOF

cat << 'EOF' > src/modules/reservations/reservations.controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ReservationsService } from './reservations.service';
import { Reservation, ReservationStatus } from './entities/reservation.entity';
import { Availability, RecurrenceType } from './entities/availability.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('reservations')
@Controller('reservations')
@ApiBearerAuth()
export class ReservationsController {
  constructor(private readonly reservationsService: ReservationsService) {}

  @Get()
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Get all reservations (admin only)' })
  findAll() {
    return this.reservationsService.findAll();
  }

  @Get('me')
  @ApiOperation({ summary: 'Get current user reservations' })
  findUserReservations(@Req() req) {
    return this.reservationsService.findByUser(req.user.id);
  }

  @Get('host')
  @ApiOperation({ summary: 'Get host reservations' })
  findHostReservations(@Req() req) {
    return this.reservationsService.findByHost(req.user.id);
  }

  @Get('upcoming')
  @ApiOperation({ summary: 'Get upcoming reservations' })
  findUpcoming(@Req() req, @Query('isHost') isHost: boolean) {
    return this.reservationsService.findUpcoming(req.user.id, isHost);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get reservation by ID' })
  findOne(@Param('id') id: string) {
    return this.reservationsService.findById(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new reservation' })
  create(
    @Req() req,
    @Body() reservationData: {
      hostId: string;
      startTime: Date;
      endTime: Date;
      amount: number;
    },
  ) {
    return this.reservationsService.create(
      req.user.id,
      reservationData.hostId,
      new Date(reservationData.startTime),
      new Date(reservationData.endTime),
      reservationData.amount,
    );
  }

  @Put(':id/status')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Update reservation status (admin only)' })
  updateStatus(
    @Param('id') id: string,
    @Body() data: { status: ReservationStatus; reason?: string },
  ) {
    return this.reservationsService.updateStatus(id, data.status, data.reason);
  }

  @Put(':id/cancel')
  @ApiOperation({ summary: 'Cancel a reservation' })
  cancel(
    @Req() req,
    @Param('id') id: string,
    @Body('reason') reason: string,
  ) {
    return this.reservationsService.cancel(id, req.user.id, reason);
  }

  @Put(':id/reschedule')
  @ApiOperation({ summary: 'Reschedule a reservation' })
  reschedule(
    @Req() req,
    @Param('id') id: string,
    @Body() data: { startTime: Date; endTime: Date },
  ) {
    return this.reservationsService.reschedule(
      id,
      req.user.id,
      new Date(data.startTime),
      new Date(data.endTime),
    );
  }

  @Put(':id/complete')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Mark a reservation as completed (admin only)' })
  complete(@Param('id') id: string) {
    return this.reservationsService.complete(id);
  }

  // Host availability management
  @Post('availability')
  @ApiOperation({ summary: 'Create host availability' })
  createAvailability(
    @Req() req,
    @Body() data: {
      startTime: Date;
      endTime: Date;
      recurrenceType?: RecurrenceType;
      daysOfWeek?: string[];
    },
  ) {
    return this.reservationsService.createAvailability(
      req.user.id,
      new Date(data.startTime),
      new Date(data.endTime),
      data.recurrenceType,
      data.daysOfWeek,
    );
  }

  @Get('availability/:hostId')
  @ApiOperation({ summary: 'Get host availability' })
  getHostAvailability(
    @Param('hostId') hostId: string,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    return this.reservationsService.getHostAvailability(
      hostId,
      new Date(startDate),
      new Date(endDate),
    );
  }
}
EOF

# Crear el módulo de Notifications (con SendGrid)
cat << 'EOF' > src/modules/notifications/channels/email.service.ts
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as SendGrid from '@sendgrid/mail';

@Injectable()
export class EmailService {
  constructor(private configService: ConfigService) {
    SendGrid.setApiKey(this.configService.get<string>('SENDGRID_API_KEY'));
  }

  async sendEmail(
    to: string,
    subject: string,
    html: string,
    text?: string,
    from?: string,
  ): Promise<void> {
    const defaultFrom = this.configService.get<string>('SENDGRID_FROM_EMAIL');
    
    const msg = {
      to,
      from: from || defaultFrom,
      subject,
      text: text || '',
      html,
    };
    
    try {
      await SendGrid.send(msg);
    } catch (error) {
      console.error('Error sending email:', error);
      if (error.response) {
        console.error(error.response.body);
      }
      throw error;
    }
  }
}
EOF

cat << 'EOF' > src/modules/notifications/entities/notification.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum NotificationType {
  RESERVATION_CREATED = 'reservation_created',
  RESERVATION_UPDATED = 'reservation_updated',
  RESERVATION_CANCELLED = 'reservation_cancelled',
  RESERVATION_REMINDER = 'reservation_reminder',
  PAYMENT_COMPLETED = 'payment_completed',
  PAYMENT_RELEASED = 'payment_released',
  REVIEW_RECEIVED = 'review_received',
  ACHIEVEMENT_UNLOCKED = 'achievement_unlocked',
  SYSTEM = 'system',
}

export enum NotificationChannel {
  IN_APP = 'in_app',
  EMAIL = 'email',
  SMS = 'sms',
  PUSH = 'push',
}

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'enum', enum: NotificationType })
  type: NotificationType;

  @Column()
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'enum', enum: NotificationChannel })
  channel: NotificationChannel;

  @Column({ default: false })
  isRead: boolean;

  @Column({ nullable: true })
  relatedId: string;

  @Column({ type: 'json', nullable: true })
  metadata: any;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

cat << 'EOF' > src/modules/notifications/notifications.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Notification } from './entities/notification.entity';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './notifications.controller';
import { EmailService } from './channels/email.service';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Notification]),
    UsersModule,
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService, EmailService],
  exports: [NotificationsService],
})
export class NotificationsModule {}
EOF

cat << 'EOF' > src/modules/notifications/notifications.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Notification,
  NotificationType,
  NotificationChannel,
} from './entities/notification.entity';
import { EmailService } from './channels/email.service';
import { UsersService } from '../users/users.service';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private notificationsRepository: Repository<Notification>,
    private emailService: EmailService,
    private usersService: UsersService,
  ) {}

  async findAll(): Promise<Notification[]> {
    return this.notificationsRepository.find({
      order: { createdAt: 'DESC' },
    });
  }

  async findByUser(userId: string): Promise<Notification[]> {
    return this.notificationsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findUnreadByUser(userId: string): Promise<Notification[]> {
    return this.notificationsRepository.find({
      where: { userId, isRead: false },
      order: { createdAt: 'DESC' },
    });
  }

  async markAsRead(id: string): Promise<Notification> {
    await this.notificationsRepository.update(id, { isRead: true });
    return this.notificationsRepository.findOne({ where: { id } });
  }

  async markAllAsRead(userId: string): Promise<void> {
    await this.notificationsRepository.update(
      { userId, isRead: false },
      { isRead: true },
    );
  }

  async create(
    userId: string,
    type: NotificationType,
    title: string,
    message: string,
    channel: NotificationChannel,
    relatedId?: string,
    metadata?: any,
  ): Promise<Notification> {
    const notification = this.notificationsRepository.create({
      userId,
      type,
      title,
      message,
      channel,
      relatedId,
      metadata,
    });
    
    return this.notificationsRepository.save(notification);
  }

  async sendEmailNotification(
    userId: string,
    subject: string,
    htmlContent: string,
    textContent?: string,
    relatedId?: string,
    metadata?: any,
  ): Promise<void> {
    // Get user email
    const user = await this.usersService.findById(userId);
    
    // Send email
    await this.emailService.sendEmail(
      user.email,
      subject,
      htmlContent,
      textContent,
    );
    
    // Create notification record
    await this.create(
      userId,
      NotificationType.SYSTEM,
      subject,
      textContent || 'Email notification',
      NotificationChannel.EMAIL,
      relatedId,
      metadata,
    );
  }

  async sendReservationCreatedNotifications(
    reservation: any,
    user: any,
    host: any,
  ): Promise<void> {
    // Notify host
    const hostHtmlContent = `
      <h2>New Reservation Request</h2>
      <p>Hello ${host.firstName},</p>
      <p>${user.firstName} ${user.lastName} has booked a session with you on ${new Date(reservation.startTime).toLocaleString()}.</p>
      <p>Please check your dashboard for more details.</p>
    `;
    
    await this.sendEmailNotification(
      host.id,
      'New Reservation Request',
      hostHtmlContent,
      `New Reservation Request: ${user.firstName} ${user.lastName} has booked a session with you on ${new Date(reservation.startTime).toLocaleString()}.`,
      reservation.id,
      { reservationId: reservation.id },
    );
    
    // Notify user
    const userHtmlContent = `
      <h2>Reservation Confirmation</h2>
      <p>Hello ${user.firstName},</p>
      <p>Your session with ${host.firstName} ${host.lastName} has been scheduled for ${new Date(reservation.startTime).toLocaleString()}.</p>
      <p>Please check your dashboard for more details.</p>
    `;
    
    await this.sendEmailNotification(
      user.id,
      'Reservation Confirmation',
      userHtmlContent,
      `Reservation Confirmation: Your session with ${host.firstName} ${host.lastName} has been scheduled for ${new Date(reservation.startTime).toLocaleString()}.`,
      reservation.id,
      { reservationId: reservation.id },
    );
  }

  async sendReservationReminderNotifications(
    reservation: any,
    user: any,
    host: any,
  ): Promise<void> {
    // Remind host
    const hostHtmlContent = `
      <h2>Upcoming Session Reminder</h2>
      <p>Hello ${host.firstName},</p>
      <p>This is a reminder that you have a session with ${user.firstName} ${user.lastName} on ${new Date(reservation.startTime).toLocaleString()}.</p>
      <p>Please be ready to join the call a few minutes before the scheduled time.</p>
    `;
    
    await this.sendEmailNotification(
      host.id,
      'Upcoming Session Reminder',
      hostHtmlContent,
      `Upcoming Session Reminder: You have a session with ${user.firstName} ${user.lastName} on ${new Date(reservation.startTime).toLocaleString()}.`,
      reservation.id,
      { reservationId: reservation.id },
    );
    
    // Remind user
    const userHtmlContent = `
      <h2>Upcoming Session Reminder</h2>
      <p>Hello ${user.firstName},</p>
      <p>This is a reminder that you have a session with ${host.firstName} ${host.lastName} on ${new Date(reservation.startTime).toLocaleString()}.</p>
      <p>Please be ready to join the call a few minutes before the scheduled time.</p>
    `;
    
    await this.sendEmailNotification(
      user.id,
      'Upcoming Session Reminder',
      userHtmlContent,
      `Upcoming Session Reminder: You have a session with ${host.firstName} ${host.lastName} on ${new Date(reservation.startTime).toLocaleString()}.`,
      reservation.id,
      { reservationId: reservation.id },
    );
  }
}
EOF

cat << 'EOF' > src/modules/notifications/notifications.controller.ts
import {
  Controller,
  Get,
  Put,
  Param,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { Notification } from './entities/notification.entity';

@ApiTags('notifications')
@Controller('notifications')
@ApiBearerAuth()
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all notifications for current user' })
  findAll(@Req() req): Promise<Notification[]> {
    return this.notificationsService.findByUser(req.user.id);
  }

  @Get('unread')
  @ApiOperation({ summary: 'Get unread notifications for current user' })
  findUnread(@Req() req): Promise<Notification[]> {
    return this.notificationsService.findUnreadByUser(req.user.id);
  }

  @Put(':id/read')
  @ApiOperation({ summary: 'Mark notification as read' })
  markAsRead(@Param('id') id: string): Promise<Notification> {
    return this.notificationsService.markAsRead(id);
  }

  @Put('read-all')
  @ApiOperation({ summary: 'Mark all notifications as read' })
  markAllAsRead(@Req() req): Promise<void> {
    return this.notificationsService.markAllAsRead(req.user.id);
  }
}
EOF

# Crear el módulo de Gamification
cat << 'EOF' > src/modules/gamification/entities/achievement.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum AchievementTrigger {
  SESSIONS_COMPLETED = 'sessions_completed',
  RATING_THRESHOLD = 'rating_threshold',
  ACCOUNT_AGE = 'account_age',
  CUSTOM = 'custom',
}

@Entity('achievements')
export class Achievement {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ nullable: true })
  icon: string;

  @Column({ nullable: true })
  emoji: string;

  @Column({ type: 'enum', enum: AchievementTrigger })
  trigger: AchievementTrigger;

  @Column({ type: 'int' })
  threshold: number;

  @Column({ default: 0 })
  points: number;

  @Column()
  role: string; // 'user' or 'host'

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

cat << 'EOF' > src/modules/gamification/entities/user-achievement.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Achievement } from './achievement.entity';

@Entity('user_achievements')
export class UserAchievement {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  achievementId: string;

  @ManyToOne(() => Achievement)
  @JoinColumn({ name: 'achievementId' })
  achievement: Achievement;

  @CreateDateColumn()
  awardedAt: Date;
}
EOF

cat << 'EOF' > src/modules/gamification/gamification.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Achievement } from './entities/achievement.entity';
import { UserAchievement } from './entities/user-achievement.entity';
import { GamificationService } from './gamification.service';
import { GamificationController } from './gamification.controller';
import { UsersModule } from '../users/users.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Achievement, UserAchievement]),
    UsersModule,
    NotificationsModule,
  ],
  controllers: [GamificationController],
  providers: [GamificationService],
  exports: [GamificationService],
})
export class GamificationModule {}
EOF

cat << 'EOF' > src/modules/gamification/gamification.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Achievement,
  AchievementTrigger,
} from './entities/achievement.entity';
import { UserAchievement } from './entities/user-achievement.entity';
import { UsersService } from '../users/users.service';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType, NotificationChannel } from '../notifications/entities/notification.entity';

@Injectable()
export class GamificationService {
  constructor(
    @InjectRepository(Achievement)
    private achievementsRepository: Repository<Achievement>,
    @InjectRepository(UserAchievement)
    private userAchievementsRepository: Repository<UserAchievement>,
    private usersService: UsersService,
    private notificationsService: NotificationsService,
  ) {}

  async findAllAchievements(): Promise<Achievement[]> {
    return this.achievementsRepository.find({ where: { isActive: true } });
  }

  async findAchievementById(id: string): Promise<Achievement> {
    const achievement = await this.achievementsRepository.findOne({
      where: { id },
    });
    
    if (!achievement) {
      throw new NotFoundException(`Achievement with ID ${id} not found`);
    }
    
    return achievement;
  }

  async createAchievement(achievementData: Partial<Achievement>): Promise<Achievement> {
    const achievement = this.achievementsRepository.create(achievementData);
    return this.achievementsRepository.save(achievement);
  }

  async updateAchievement(
    id: string,
    achievementData: Partial<Achievement>,
  ): Promise<Achievement> {
    await this.findAchievementById(id); // Check if achievement exists
    
    await this.achievementsRepository.update(id, achievementData);
    return this.findAchievementById(id);
  }

  async deleteAchievement(id: string): Promise<void> {
    await this.findAchievementById(id); // Check if achievement exists
    await this.achievementsRepository.delete(id);
  }

  async getUserAchievements(userId: string): Promise<UserAchievement[]> {
    return this.userAchievementsRepository.find({
      where: { userId },
      relations: ['achievement'],
    });
  }

  async awardAchievement(
    userId: string,
    achievementId: string,
  ): Promise<UserAchievement> {
    // Check if user already has this achievement
    const existingAward = await this.userAchievementsRepository.findOne({
      where: { userId, achievementId },
    });
    
    if (existingAward) {
      return existingAward;
    }
    
    // Get achievement details
    const achievement = await this.findAchievementById(achievementId);
    
    // Create user achievement
    const userAchievement = this.userAchievementsRepository.create({
      userId,
      achievementId,
    });
    
    const savedAward = await this.userAchievementsRepository.save(userAchievement);
    
    // Award points
    if (achievement.points > 0) {
      await this.usersService.updatePoints(userId, achievement.points);
    }
    
    // Send notification
    await this.notificationsService.create(
      userId,
      NotificationType.ACHIEVEMENT_UNLOCKED,
      'Achievement Unlocked!',
      `You've earned the "${achievement.name}" achievement: ${achievement.description}`,
      NotificationChannel.IN_APP,
      achievement.id,
      { achievementId: achievement.id },
    );
    
    return savedAward;
  }

  async checkSessionsAchievements(userId: string, sessionCount: number, isHost: boolean): Promise<void> {
    // Find all achievements related to session count for this user type
    const eligibleAchievements = await this.achievementsRepository.find({
      where: {
        trigger: AchievementTrigger.SESSIONS_COMPLETED,
        role: isHost ? 'host' : 'user',
        threshold: sessionCount, // Exact match for simplicity
        isActive: true,
      },
    });
    
    // Award each eligible achievement
    for (const achievement of eligibleAchievements) {
      await this.awardAchievement(userId, achievement.id);
    }
  }

  async checkRatingAchievements(userId: string, rating: number): Promise<void> {
    // Find all achievements related to rating thresholds
    const eligibleAchievements = await this.achievementsRepository.find({
      where: {
        trigger: AchievementTrigger.RATING_THRESHOLD,
        role: 'host', // Only hosts get rating achievements
        threshold: rating, // Simplified: exact match of average rating
        isActive: true,
      },
    });
    
    // Award each eligible achievement
    for (const achievement of eligibleAchievements) {
      await this.awardAchievement(userId, achievement.id);
    }
  }
}
EOF

cat << 'EOF' > src/modules/gamification/gamification.controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { GamificationService } from './gamification.service';
import { Achievement } from './entities/achievement.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('gamification')
@Controller('gamification')
@ApiBearerAuth()
export class GamificationController {
  constructor(private readonly gamificationService: GamificationService) {}

  @Get('achievements')
  @ApiOperation({ summary: 'Get all achievements' })
  findAllAchievements(): Promise<Achievement[]> {
    return this.gamificationService.findAllAchievements();
  }

  @Get('achievements/:id')
  @ApiOperation({ summary: 'Get achievement by ID' })
  findAchievementById(@Param('id') id: string): Promise<Achievement> {
    return this.gamificationService.findAchievementById(id);
  }

  @Post('achievements')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Create a new achievement (admin only)' })
  createAchievement(@Body() achievementData: Partial<Achievement>): Promise<Achievement> {
    return this.gamificationService.createAchievement(achievementData);
  }

  @Put('achievements/:id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Update an achievement (admin only)' })
  updateAchievement(
    @Param('id') id: string,
    @Body() achievementData: Partial<Achievement>,
  ): Promise<Achievement> {
    return this.gamificationService.updateAchievement(id, achievementData);
  }

  @Delete('achievements/:id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Delete an achievement (admin only)' })
  deleteAchievement(@Param('id') id: string): Promise<void> {
    return this.gamificationService.deleteAchievement(id);
  }

  @Get('my-achievements')
  @ApiOperation({ summary: 'Get current user achievements' })
  getUserAchievements(@Req() req) {
    return this.gamificationService.getUserAchievements(req.user.id);
  }

  @Post('award')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Award an achievement to a user (admin only)' })
  awardAchievement(
    @Body() data: { userId: string; achievementId: string },
  ) {
    return this.gamificationService.awardAchievement(
      data.userId,
      data.achievementId,
    );
  }
}
EOF

# Crear el módulo de Admin
cat << 'EOF' > src/modules/admin/entities/theme-settings.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('theme_settings')
export class ThemeSettings {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ default: '#3366FF' })
  primaryColor: string;

  @Column({ default: '#333333' })
  secondaryColor: string;

  @Column({ default: '#FFFFFF' })
  backgroundColor: string;

  @Column({ default: '#F5F5F5' })
  surfaceColor: string;

  @Column({ default: '#e74c3c' })
  errorColor: string;

  @Column({ default: '#2ecc71' })
  successColor: string;

  @Column({ default: '#f39c12' })
  warningColor: string;

  @Column({ default: '#3498db' })
  infoColor: string;

  @Column({ default: "'Roboto', sans-serif" })
  fontFamily: string;

  @Column({ default: "'Poppins', sans-serif" })
  headingFontFamily: string;

  @Column({ default: '14px' })
  baseFontSize: string;

  @Column({ default: '4px' })
  borderRadius: string;

  @Column({ type: 'json', nullable: true })
  customCss: any;

  @Column({ nullable: true })
  logoUrl: string;

  @Column({ nullable: true })
  faviconUrl: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

cat << 'EOF' > src/modules/admin/entities/content.entity.ts
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum ContentType {
  NEWS = 'news',
  ANNOUNCEMENT = 'announcement',
  PROMOTION = 'promotion',
  BANNER = 'banner',
}

@Entity('contents')
export class Content {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'enum', enum: ContentType })
  type: ContentType;

  @Column()
  title: string;

  @Column({ type: 'text' })
  body: string;

  @Column({ nullable: true })
  imageUrl: string;

  @Column({ nullable: true })
  linkUrl: string;

  @Column({ nullable: true })
  linkText: string;

  @Column({ default: true })
  isActive: boolean;

  @Column({ type: 'timestamp', nullable: true })
  startDate: Date;

  @Column({ type: 'timestamp', nullable: true })
  endDate: Date;

  @Column({ default: false })
  isPinned: boolean;

  @Column({ default: 0 })
  displayOrder: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
EOF

cat << 'EOF' > src/modules/admin/admin.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThemeSettings } from './entities/theme-settings.entity';
import { Content } from './entities/content.entity';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { UsersModule } from '../users/users.module';
import { HostsModule } from '../hosts/hosts.module';
import { ReservationsModule } from '../reservations/reservations.module';
import { PaymentsModule } from '../payments/payments.module';
import { GamificationModule } from '../gamification/gamification.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([ThemeSettings, Content]),
    UsersModule,
    HostsModule,
    ReservationsModule,
    PaymentsModule,
    GamificationModule,
  ],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}
EOF

cat << 'EOF' > src/modules/admin/admin.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ThemeSettings } from './entities/theme-settings.entity';
import { Content, ContentType } from './entities/content.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(ThemeSettings)
    private themeSettingsRepository: Repository<ThemeSettings>,
    @InjectRepository(Content)
    private contentRepository: Repository<Content>,
  ) {}

  // Theme Settings
  async getThemeSettings(): Promise<ThemeSettings> {
    const settings = await this.themeSettingsRepository.find({
      take: 1,
      order: { createdAt: 'DESC' },
    });
    
    if (settings.length === 0) {
      // Create default theme settings if none exist
      return this.themeSettingsRepository.save(
        this.themeSettingsRepository.create(),
      );
    }
    
    return settings[0];
  }

  async updateThemeSettings(
    themeData: Partial<ThemeSettings>,
  ): Promise<ThemeSettings> {
    const settings = await this.getThemeSettings();
    
    // Update fields
    Object.assign(settings, themeData);
    
    return this.themeSettingsRepository.save(settings);
  }

  // Content Management
  async getAllContent(): Promise<Content[]> {
    return this.contentRepository.find({
      order: { 
        isPinned: 'DESC',
        displayOrder: 'ASC',
        createdAt: 'DESC',
      },
    });
  }

  async getActiveContent(): Promise<Content[]> {
    const now = new Date();
    
    return this.contentRepository.find({
      where: [
        {
          isActive: true,
          startDate: null,
          endDate: null,
        },
        {
          isActive: true,
          startDate: null,
          endDate: MoreThanOrEqual(now),
        },
        {
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: null,
        },
        {
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: MoreThanOrEqual(now),
        },
      ],
      order: {
        isPinned: 'DESC',
        displayOrder: 'ASC',
        createdAt: 'DESC',
      },
    });
  }

  async getContentByType(type: ContentType): Promise<Content[]> {
    const now = new Date();
    
    return this.contentRepository.find({
      where: [
        {
          type,
          isActive: true,
          startDate: null,
          endDate: null,
        },
        {
          type,
          isActive: true,
          startDate: null,
          endDate: MoreThanOrEqual(now),
        },
        {
          type,
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: null,
        },
        {
          type,
          isActive: true,
          startDate: LessThanOrEqual(now),
          endDate: MoreThanOrEqual(now),
        },
      ],
      order: {
        isPinned: 'DESC',
        displayOrder: 'ASC',
        createdAt: 'DESC',
      },
    });
  }

  async getContentById(id: string): Promise<Content> {
    const content = await this.contentRepository.findOne({
      where: { id },
    });
    
    if (!content) {
      throw new NotFoundException(`Content with ID ${id} not found`);
    }
    
    return content;
  }

  async createContent(contentData: Partial<Content>): Promise<Content> {
    const content = this.contentRepository.create(contentData);
    return this.contentRepository.save(content);
  }

  async updateContent(
    id: string,
    contentData: Partial<Content>,
  ): Promise<Content> {
    await this.getContentById(id); // Check if content exists
    
    await this.contentRepository.update(id, contentData);
    return this.getContentById(id);
  }

  async deleteContent(id: string): Promise<void> {
    await this.getContentById(id); // Check if content exists
    await this.contentRepository.delete(id);
  }
}
EOF

cat << 'EOF' > src/modules/admin/admin.controller.ts
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { ThemeSettings } from './entities/theme-settings.entity';
import { Content, ContentType } from './entities/content.entity';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('admin')
@Controller('admin')
@Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
@UseGuards(RolesGuard)
@ApiBearerAuth()
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  // Theme Settings
  @Get('theme')
  @ApiOperation({ summary: 'Get theme settings' })
  getThemeSettings(): Promise<ThemeSettings> {
    return this.adminService.getThemeSettings();
  }

  @Put('theme')
  @ApiOperation({ summary: 'Update theme settings' })
  updateThemeSettings(
    @Body() themeData: Partial<ThemeSettings>,
  ): Promise<ThemeSettings> {
    return this.adminService.updateThemeSettings(themeData);
  }

  // Content Management
  @Get('content')
  @ApiOperation({ summary: 'Get all content' })
  getAllContent(): Promise<Content[]> {
    return this.adminService.getAllContent();
  }

  @Get('content/active')
  @ApiOperation({ summary: 'Get active content' })
  getActiveContent(): Promise<Content[]> {
    return this.adminService.getActiveContent();
  }

  @Get('content/type/:type')
  @ApiOperation({ summary: 'Get content by type' })
  getContentByType(@Param('type') type: ContentType): Promise<Content[]> {
    return this.adminService.getContentByType(type);
  }

  @Get('content/:id')
  @ApiOperation({ summary: 'Get content by ID' })
  getContentById(@Param('id') id: string): Promise<Content> {
    return this.adminService.getContentById(id);
  }

  @Post('content')
  @ApiOperation({ summary: 'Create new content' })
  createContent(@Body() contentData: Partial<Content>): Promise<Content> {
    return this.adminService.createContent(contentData);
  }

  @Put('content/:id')
  @ApiOperation({ summary: 'Update content' })
  updateContent(
    @Param('id') id: string,
    @Body() contentData: Partial<Content>,
  ): Promise<Content> {
    return this.adminService.updateContent(id, contentData);
  }

  @Delete('content/:id')
  @ApiOperation({ summary: 'Delete content' })
  deleteContent(@Param('id') id: string): Promise<void> {
    return this.adminService.deleteContent(id);
  }
}
EOF

# Crear módulo i18n
cat << 'EOF' > src/modules/i18n/i18n.module.ts
import { Global, Module } from '@nestjs/common';
import { I18nService } from './i18n.service';

@Global()
@Module({
  providers: [I18nService],
  exports: [I18nService],
})
export class I18nModule {}
EOF

cat << 'EOF' > src/modules/i18n/i18n.service.ts
import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class I18nService {
  private translations: Record<string, any> = {};
  private defaultLocale = 'es';

  constructor() {
    this.loadTranslations();
  }

  private loadTranslations() {
    const localesDir = path.join(process.cwd(), 'locales');
    
    if (!fs.existsSync(localesDir)) {
      console.warn('Locales directory not found, translations will not be available');
      return;
    }
    
    try {
      const localeFiles = fs.readdirSync(localesDir);
      
      for (const file of localeFiles) {
        if (file.endsWith('.json') || file.endsWith('.yaml')) {
          const locale = file.split('.')[0];
          const filePath = path.join(localesDir, file);
          const content = fs.readFileSync(filePath, 'utf8');
          
          if (file.endsWith('.json')) {
            this.translations[locale] = JSON.parse(content);
          } else if (file.endsWith('.yaml')) {
            // Simple YAML parsing (for production, use a proper YAML parser)
            const yamlObj = {};
            const lines = content.split('\n');
            let currentSection = yamlObj;
            let sectionStack = [yamlObj];
            let indentStack = [0];
            
            for (const line of lines) {
              const trimmedLine = line.trimEnd();
              if (!trimmedLine || trimmedLine.startsWith('#')) continue;
              
              const indent = line.search(/\S/);
              const keyValueMatch = trimmedLine.match(/^(\s*)([^:]+):\s*(.*)$/);
              
              if (keyValueMatch) {
                const [, , key, value] = keyValueMatch;
                
                // Handle indentation changes
                if (indent > indentStack[indentStack.length - 1]) {
                  // Deeper level
                  sectionStack.push(currentSection[sectionStack[sectionStack.length - 1]]);
                  indentStack.push(indent);
                } else if (indent < indentStack[indentStack.length - 1]) {
                  // Go back up
                  while (indent < indentStack[indentStack.length - 1]) {
                    sectionStack.pop();
                    indentStack.pop();
                  }
                }
                
                // Set value
                if (value.trim() === '') {
                  currentSection[key.trim()] = {};
                } else {
                  // Remove quotes if present
                  const cleanValue = value.trim().replace(/^['"](.*)['"]$/, '$1');
                  currentSection[key.trim()] = cleanValue;
                }
              }
            }
            
            this.translations[locale] = yamlObj;
          }
        }
      }
    } catch (error) {
      console.error('Error loading translations:', error);
    }
  }

  translate(key: string, locale: string = this.defaultLocale, params: Record<string, any> = {}): string {
    const keys = key.split('.');
    const language = this.translations[locale] || this.translations[this.defaultLocale] || {};
    
    // Navigate through the keys
    let result = language;
    for (const k of keys) {
      result = result?.[k];
      if (result === undefined) break;
    }
    
    if (typeof result !== 'string') {
      // Try default locale if not found
      if (locale !== this.defaultLocale) {
        return this.translate(key, this.defaultLocale, params);
      }
      return key; // Fallback to key
    }
    
    // Replace parameters
    return result.replace(/\{(\w+)\}/g, (_, param) => {
      return params[param] !== undefined ? params[param] : `{${param}}`;
    });
  }

  // Alias for translate
  t(key: string, locale: string = this.defaultLocale, params: Record<string, any> = {}): string {
    return this.translate(key, locale, params);
  }

  getAvailableLocales(): string[] {
    return Object.keys(this.translations);
  }
}
EOF

# Crear archivos para tests
cat << 'EOF' > test/app.e2e-spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        transform: true,
      }),
    );
    await app.init();
  });

  it('/api/health (GET)', () => {
    return request(app.getHttpServer()).get('/api/health').expect(200);
  });

  afterAll(async () => {
    await app.close();
  });
});
EOF

# Crear archivos de locale
mkdir -p locales

cat << 'EOF' > locales/en.json
{
  "errors": {
    "unexpected_error": "An unexpected error occurred. Please try again later.",
    "invalid_credentials": "Invalid username or password.",
    "unauthorized": "You are not authorized to perform this action.",
    "forbidden": "Access forbidden.",
    "not_found": "Resource not found.",
    "user_not_found": "User not found.",
    "email_exists": "This email address is already in use."
  },
  "validation": {
    "required_field": "This field is required.",
    "invalid_email": "Please enter a valid email address.",
    "min_length": "Must be at least {min} characters.",
    "max_length": "Must be at most {max} characters.",
    "password_mismatch": "Passwords do not match."
  },
  "notifications": {
    "new_message": "New message from {name}.",
    "meeting_reminder": "Reminder: Meeting \"{title}\" at {time}.",
    "new_notification": "You have a new notification.",
    "account_approved": "Your account has been approved."
  },
  "emails": {
    "welcome_subject": "Welcome to Dialoom!",
    "welcome_body": "Hello {name},\n\nThank you for joining Dialoom. We're excited to have you on board. If you have any questions, feel free to contact our support team.\n\nBest regards,\nThe Dialoom Team"
  },
  "general": {
    "ok": "OK",
    "cancel": "Cancel",
    "confirm": "Confirm",
    "yes": "Yes",
    "no": "No",
    "back": "Back",
    "next": "Next",
    "close": "Close",
    "save": "Save",
    "delete": "Delete",
    "search": "Search",
    "login": "Log In",
    "logout": "Log Out",
    "sign_up": "Sign Up",
    "profile": "Profile",
    "settings": "Settings"
  }
}
EOF

cat << 'EOF' > locales/es.json
{
  "errors": {
    "unexpected_error": "Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo más tarde.",
    "invalid_credentials": "Usuario o contraseña incorrectos.",
    "unauthorized": "No estás autorizado para realizar esta acción.",
    "forbidden": "Acceso prohibido.",
    "not_found": "Recurso no encontrado.",
    "user_not_found": "Usuario no encontrado.",
    "email_exists": "Esta dirección de correo electrónico ya está en uso."
  },
  "validation": {
    "required_field": "Este campo es obligatorio.",
    "invalid_email": "Por favor, introduzca una dirección de correo electrónico válida.",
    "min_length": "Debe tener al menos {min} caracteres.",
    "max_length": "Debe tener como máximo {max} caracteres.",
    "password_mismatch": "Las contraseñas no coinciden."
  },
  "notifications": {
    "new_message": "Nuevo mensaje de {name}.",
    "meeting_reminder": "Recordatorio: Reunión \"{title}\" a las {time}.",
    "new_notification": "Tienes una nueva notificación.",
    "account_approved": "Tu cuenta ha sido aprobada."
  },
  "emails": {
    "welcome_subject": "¡Bienvenido a Dialoom!",
    "welcome_body": "Hola {name},\n\nGracias por unirte a Dialoom. Estamos encantados de tenerte con nosotros. Si tienes alguna pregunta, no dudes en contactar a nuestro equipo de soporte.\n\nSaludos,\nEl equipo de Dialoom"
  },
  "general": {
    "ok": "Aceptar",
    "cancel": "Cancelar",
    "confirm": "Confirmar",
    "yes": "Sí",
    "no": "No",
    "back": "Atrás",
    "next": "Siguiente",
    "close": "Cerrar",
    "save": "Guardar",
    "delete": "Eliminar",
    "search": "Buscar",
    "login": "Iniciar sesión",
    "logout": "Cerrar sesión",
    "sign_up": "Registrarse",
    "profile": "Perfil",
    "settings": "Configuración"
  }
}
EOF

# Script para instalación y desarrollo
cat << 'EOF' > setup.sh
#!/usr/bin/env bash

# Configurar el backend de Dialoom
echo "=== Configurando el backend de Dialoom ==="

# Crear archivo .env desde .env.example
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Archivo .env creado desde .env.example. Por favor, actualiza las credenciales según sea necesario."
fi

# Instalar dependencias
echo "Instalando dependencias..."
npm install

# Solicitar iniciar la aplicación
echo ""
echo "Configuración completa. Para iniciar la aplicación en modo desarrollo, ejecuta:"
echo "npm run start:dev"
echo ""
echo "Para compilar la aplicación para producción:"
echo "npm run build"
echo ""
echo "Para iniciar en modo producción:"
echo "npm run start:prod"
EOF

chmod +x setup.sh

# Volver al directorio original y mostrar mensaje final
cd ..
echo "=== Estructura de Dialoom Backend generada exitosamente ==="
echo "Se ha creado la carpeta ./dialoom-backend con todos los archivos necesarios."
echo "Para configurar el backend:"
echo "1. cd dialoom-backend"
echo "2. chmod +x setup.sh"
echo "3. ./setup.sh"
echo "4. Edita el archivo .env con tus credenciales"
echo "5. npm run start:dev para iniciar el desarrollo"
echo ""
echo "La API estará disponible en http://localhost:3000/api"
echo "La documentación de la API estará disponible en http://localhost:3000/api/docs"