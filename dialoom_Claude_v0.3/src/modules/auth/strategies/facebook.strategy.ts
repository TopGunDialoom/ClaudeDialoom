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
