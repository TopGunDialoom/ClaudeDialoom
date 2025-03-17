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
