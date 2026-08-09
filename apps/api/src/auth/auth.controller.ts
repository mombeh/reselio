import {
  Controller,
  Post,
  Body,
  UnauthorizedException,
  Get,
  UseGuards,
  Req,
  Res,
  Logger,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import type { Response } from 'express';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { GoogleAuthGuard } from './guards/google-auth.guard';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { LoginUserDto } from '../users/dto/login-user.dto';

@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);

  constructor(
    private authService: AuthService,
    private usersService: UsersService,
  ) {}

  @Post('register')
  async register(@Body() createUserDto: CreateUserDto) {
    const user = await this.usersService.create(createUserDto);
    return this.authService.login(user);
  }

  @Post('login')
  async login(@Body() loginUserDto: LoginUserDto) {
    const user = await this.authService.validateUser(
      loginUserDto.email,
      loginUserDto.password,
    );
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.authService.login(user);
  }

  @Get('google')
  @UseGuards(GoogleAuthGuard)
  async googleAuth(@Req() req: any) {}

  @Get('google/callback')
  @UseGuards(GoogleAuthGuard)
  async googleAuthRedirect(@Req() req: any, @Res() res: Response) {
    try {
      this.logger.log('Google callback received, user:', req.user);

      if (!req.user || !req.user.email) {
        this.logger.error('No user data from Google OAuth');
        const frontendUrl =
          process.env.FRONTEND_URL || 'https://reselio-web.vercel.app';
        return res.redirect(`${frontendUrl}/auth/login?error=no_user_data`);
      }

      const result = await this.authService.googleLogin(req.user);
      this.logger.log('Google login successful, redirecting');

      // Redirect to frontend callback with token and user data
      const frontendUrl =
        process.env.FRONTEND_URL || 'https://reselio-web.vercel.app';
      const callbackUrl = `${frontendUrl}/auth/callback?token=${encodeURIComponent(result.access_token)}`;
      return res.redirect(callbackUrl);
    } catch (error) {
      this.logger.error('Google callback error:', error);
      const frontendUrl =
        process.env.FRONTEND_URL || 'https://reselio-web.vercel.app';
      return res.redirect(`${frontendUrl}/auth/login?error=auth_failed`);
    }
  }
  @Post('google/mobile')
  async googleMobile(
    @Body()
    body: {
      accessToken: string;
    },
  ) {
    const result = await this.authService.googleMobileLogin(body.accessToken);
    return result;
  }
  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  getProfile(@Req() req: any) {
    return req.user;
  }

  @Post('logout')
  @UseGuards(AuthGuard('jwt'))
  logout() {
    return { message: 'Logged out successfully' };
  }
}
