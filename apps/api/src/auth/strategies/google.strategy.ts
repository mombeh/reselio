import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, type VerifyCallback } from 'passport-google-oauth20';
import { GoogleUser } from '../interfaces/google-user.interface';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor(configService: ConfigService) {
    // Debug logging to help identify issues
    const appUrl = configService.get<string>('APP_URL') || '';
    const frontendUrl = configService.get<string>('FRONTEND_URL') || '';
    
    console.log('[GoogleStrategy] APP_URL:', appUrl);
    console.log('[GoogleStrategy] FRONTEND_URL:', frontendUrl);
    
    // Use production redirect URI when APP_URL is set to production domain
    // Use localhost redirect only when running truly locally (no APP_URL or localhost in APP_URL)
    const isProduction = appUrl && !appUrl.includes('localhost') && appUrl.includes('render.com');
    
    // Use appropriate redirect URI based on environment
    const redirectUri = isProduction 
      ? configService.get<string>('GOOGLE_REDIRECT_URI')
      : configService.get<string>('GOOGLE_REDIRECT_URI_LOCAL');
    
    console.log('[GoogleStrategy] isProduction:', isProduction);
    console.log('[GoogleStrategy] redirectUri (actual):', redirectUri);
    
    super({
      clientID: configService.get<string>('GOOGLE_CLIENT_ID') || '',
      clientSecret: configService.get<string>('GOOGLE_CLIENT_SECRET') || '',
      callbackURL: redirectUri || '',
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
