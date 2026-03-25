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
  ): Promise<GoogleUser | undefined> {
    try {
      console.log('Google validate - profile id:', profile?.id);
      const { id, displayName, emails, photos } = profile;

      if (!emails || !emails[0]?.value) {
        console.error('Google validate - no email found in profile');
        done(new Error('No email found in Google profile'));
        return undefined;
      }

      const user: GoogleUser = {
        googleId: id,
        email: emails[0].value,
        name: displayName || '',
        picture: photos?.[0]?.value || '',
        accessToken,
      };

      console.log('Google validate - user email:', user.email);
      done(null, user);
      return user;
    } catch (error) {
      console.error('Google validate error:', error);
      done(error);
      return undefined;
    }
  }
}
