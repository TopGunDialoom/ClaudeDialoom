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
