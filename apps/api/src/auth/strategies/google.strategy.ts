import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, type VerifyCallback } from 'passport-google-oauth20';
import { GoogleUser } from '../interfaces/google-user.interface';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor() {
    super({
      clientID: process.env.GOOGLE_CLIENT_ID || '',
      clientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
      callbackURL: process.env.GOOGLE_REDIRECT_URI || '',
      scope: ['email', 'profile'],
    });
  }

  async validate(
    accessToken: string,
    _refreshToken: string,
    profile: any,
    done: VerifyCallback,
  ): Promise<GoogleUser> {
    const { id, displayName, emails, photos } = profile;

    const user: GoogleUser = {
      googleId: id,
      email: emails?.[0]?.value || '',
      name: displayName || '',
      picture: photos?.[0]?.value || '',
      accessToken,
    };

    done(null, user);
    return user;
  }
}
