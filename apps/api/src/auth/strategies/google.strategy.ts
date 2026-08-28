import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, type VerifyCallback } from 'passport-google-oauth20';
import { GoogleUser } from '../interfaces/google-user.interface';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor(configService: ConfigService) {
    // Simply use the redirect URI that matches the current environment
    // The GOOGLE_REDIRECT_URI is set to the production callback for deployed
    // The GOOGLE_REDIRECT_URI_LOCAL is set to localhost for local dev
    const redirectUri =
      configService.get<string>('GOOGLE_REDIRECT_URI') ||
      configService.get<string>('GOOGLE_REDIRECT_URI_LOCAL') ||
      '';

    const clientID = configService.get<string>('GOOGLE_CLIENT_ID') || 'dummy-client-id';
    const clientSecret =
      configService.get<string>('GOOGLE_CLIENT_SECRET') || 'dummy-client-secret';

    if (!configService.get<string>('GOOGLE_CLIENT_ID') || !configService.get<string>('GOOGLE_CLIENT_SECRET')) {
      Logger.warn('Google OAuth is not configured. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET in environment variables.', 'GoogleStrategy');
    }

    super({
      clientID,
      clientSecret,
      callbackURL: redirectUri,
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

    if (!emails || !emails[0]?.value) {
      done(new Error('No email provided by Google'), undefined);
      return {} as GoogleUser;
    }

    const user: GoogleUser = {
      googleId: id,
      email: emails[0].value,
      name: displayName || '',
      picture: photos?.[0]?.value || '',
      accessToken,
    };

    done(null, user);
    return user;
  }
}
