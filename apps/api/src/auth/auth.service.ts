import { Injectable, Logger } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(email: string, password: string) {
    return this.usersService.validateUser(email, password);
  }

  async login(user: any) {
    const payload = { email: user.email, sub: user._id };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
      },
    };
  }

  async googleMobileLogin(accessToken: string) {
    const profile = await fetch(
      'https://www.googleapis.com/oauth2/v3/userinfo',
      {
        headers: { Authorization: `Bearer ${accessToken}` },
      },
    ).then((res) => {
      if (!res.ok) throw new Error('Invalid Google access token');
      return res.json();
    });

    const email = profile.email;
    if (!email) {
      throw new Error('No email provided by Google');
    }

    if (!profile.email_verified) {
      throw new Error('Google email is not verified');
    }

    let user = await this.usersService.findByEmail(email);

    if (!user) {
      const randomPassword = Math.random().toString(36).slice(-16);
      const hashedPassword = await bcrypt.hash(randomPassword, 10);
      user = await this.usersService.createWithGoogle(
        email,
        profile.name || email.split('@')[0],
        hashedPassword,
      );
    }

    const payload = { email: user.email, sub: user._id };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
      },
    };
  }

  async googleLogin(googleUser: any) {
    try {
      this.logger.log('Processing Google login for:', googleUser.email);

      if (!googleUser.email) {
        throw new Error('No email provided by Google');
      }

      // Check if user already exists
      let user = await this.usersService.findByEmail(googleUser.email);

      if (!user) {
        this.logger.log('Creating new user from Google OAuth');
        // Create new user with Google profile
        const randomPassword = Math.random().toString(36).slice(-16);
        const hashedPassword = await bcrypt.hash(randomPassword, 10);

        user = await this.usersService.createWithGoogle(
          googleUser.email,
          googleUser.name,
          hashedPassword,
        );
      }

      this.logger.log('User found/created, generating JWT');

      // Generate JWT token
      const payload = { email: user.email, sub: user._id };
      return {
        access_token: this.jwtService.sign(payload),
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
        },
      };
    } catch (error) {
      this.logger.error('Error in googleLogin:', error);
      throw error;
    }
  }
}
