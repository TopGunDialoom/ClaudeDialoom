#!/bin/bash

echo "Corrigiendo estrategias de autenticación (versión 2)..."

# 1. Corregir AppleStrategy
cat > src/modules/auth/strategies/apple.strategy.ts << 'EOF'
import { Injectable, Logger } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-apple';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';

@Injectable()
export class AppleStrategy extends PassportStrategy(Strategy, 'apple') {
  private readonly logger = new Logger(AppleStrategy.name);

  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    const clientID = configService.get<string>('APPLE_CLIENT_ID') || 'dummy-client-id';
    const teamID = configService.get<string>('APPLE_TEAM_ID') || 'dummy-team-id';
    const keyID = configService.get<string>('APPLE_KEY_ID') || 'dummy-key-id';
    const privateKey = configService.get<string>('APPLE_PRIVATE_KEY') || 'dummy-private-key';
    const callbackURL = configService.get<string>('APPLE_CALLBACK_URL') || 'http://localhost:3000/auth/apple/callback';

    // La llamada a super debe ser la primera instrucción en el constructor
    super({
      clientID,
      teamID,
      keyID,
      privateKeyString: privateKey,
      callbackURL,
      passReqToCallback: false,
      scope: ['email', 'name'],
    });
    
    // Verificamos después si las credenciales son reales
    const hasRealCredentials = 
      configService.get<string>('APPLE_CLIENT_ID') && 
      configService.get<string>('APPLE_TEAM_ID') &&
      configService.get<string>('APPLE_KEY_ID') &&
      configService.get<string>('APPLE_PRIVATE_KEY');
      
    if (!hasRealCredentials) {
      this.logger.warn('Apple OAuth credentials not provided or incomplete. Apple auth will not work properly.');
    }
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
        id: idToken?.sub || 'unknown',
        emails: [{ value: idToken?.email || 'unknown@example.com' }],
        displayName: profile?.name?.firstName
          ? `${profile.name.firstName} ${profile.name.lastName || ''}`
          : 'Apple User',
        name: profile?.name || { firstName: 'Apple', lastName: 'User' },
      };

      const user = await this.authService.validateOAuthUser(profileData, 'apple');
      done(null, user);
    } catch (error) {
      done(error, null);
    }
  }
}
EOF

# 2. Corregir GoogleStrategy
cat > src/modules/auth/strategies/google.strategy.ts << 'EOF'
import { Injectable, Logger } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback } from 'passport-google-oauth20';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  private readonly logger = new Logger(GoogleStrategy.name);

  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    const clientID = configService.get<string>('GOOGLE_CLIENT_ID') || 'dummy-client-id';
    const clientSecret = configService.get<string>('GOOGLE_CLIENT_SECRET') || 'dummy-client-secret';
    const callbackURL = configService.get<string>('GOOGLE_CALLBACK_URL') || 'http://localhost:3000/auth/google/callback';

    // La llamada a super debe ser la primera instrucción en el constructor
    super({
      clientID,
      clientSecret,
      callbackURL,
      scope: ['email', 'profile'],
    });
    
    // Verificamos después si las credenciales son reales
    const hasRealCredentials = 
      configService.get<string>('GOOGLE_CLIENT_ID') && 
      configService.get<string>('GOOGLE_CLIENT_SECRET');
      
    if (!hasRealCredentials) {
      this.logger.warn('Google OAuth credentials not provided or incomplete. Google auth will not work properly.');
    }
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

# 3. Corregir FacebookStrategy
cat > src/modules/auth/strategies/facebook.strategy.ts << 'EOF'
import { Injectable, Logger } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-facebook';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';

@Injectable()
export class FacebookStrategy extends PassportStrategy(Strategy, 'facebook') {
  private readonly logger = new Logger(FacebookStrategy.name);

  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    const clientID = configService.get<string>('FACEBOOK_APP_ID') || 'dummy-client-id';
    const clientSecret = configService.get<string>('FACEBOOK_APP_SECRET') || 'dummy-client-secret';
    const callbackURL = configService.get<string>('FACEBOOK_CALLBACK_URL') || 'http://localhost:3000/auth/facebook/callback';

    // La llamada a super debe ser la primera instrucción en el constructor
    super({
      clientID,
      clientSecret,
      callbackURL,
      scope: ['email', 'public_profile'],
      profileFields: ['id', 'emails', 'name', 'displayName'],
    });
    
    // Verificamos después si las credenciales son reales
    const hasRealCredentials = 
      configService.get<string>('FACEBOOK_APP_ID') && 
      configService.get<string>('FACEBOOK_APP_SECRET');
      
    if (!hasRealCredentials) {
      this.logger.warn('Facebook OAuth credentials not provided or incomplete. Facebook auth will not work properly.');
    }
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

# 4. Corregir servicio de Email (SendGrid) - No necesita cambios en este aspecto
cat > src/modules/notifications/channels/email.service.ts << 'EOF'
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as SendGrid from '@sendgrid/mail';

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private readonly isConfigured: boolean;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('SENDGRID_API_KEY') || '';
    this.isConfigured = apiKey && apiKey.startsWith('SG.');
    
    if (this.isConfigured) {
      SendGrid.setApiKey(apiKey);
    } else {
      this.logger.warn('SendGrid API key not properly configured. Email sending will be simulated.');
    }
  }

  async sendEmail(
    to: string,
    subject: string,
    html: string,
    text?: string,
    from?: string,
  ): Promise<void> {
    const defaultFrom = this.configService.get<string>('SENDGRID_FROM_EMAIL') || 'noreply@example.com';
    
    const msg = {
      to,
      from: from || defaultFrom,
      subject,
      text: text || '',
      html,
    };
    
    if (!this.isConfigured) {
      this.logger.log(`[SIMULATED EMAIL] To: ${to}, Subject: ${subject}`);
      return;
    }
    
    try {
      await SendGrid.send(msg);
    } catch (error) {
      this.logger.error('Error sending email:', error);
      if (error.response) {
        this.logger.error(error.response.body);
      }
      // No relanzamos el error para que la aplicación pueda continuar funcionando
    }
  }
}
EOF

echo "✅ Estrategias de autenticación corregidas (versión 2). Ahora la aplicación debería compilar correctamente."