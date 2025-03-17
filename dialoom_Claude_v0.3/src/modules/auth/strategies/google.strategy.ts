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
