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
