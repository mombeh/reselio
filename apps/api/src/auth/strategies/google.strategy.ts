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
    const redirectUri = configService.get<string>('GOOGLE_REDIRECT_URI') || 
                       configService.get<string>('GOOGLE_REDIRECT_URI_LOCAL') || '';
    
    const clientID = configService.get<string>('GOOGLE_CLIENT_ID') || '';
    const clientSecret = configService.get<string>('GOOGLE_CLIENT_SECRET') || '';
    
    super({
      clientID,
      clientSecret,
      callbackURL: redirectUri,
      scope: ['email', 'profile'],
    });
    
    // Use console since Logger is not available before super() call
    console.log('[GoogleStrategy] Using redirectUri:', redirectUri);
    console.log('[GoogleStrategy] ClientID present:', !!clientID);
    console.log('[GoogleStrategy] ClientSecret present:', !!clientSecret);
  }

  async validate(
    accessToken: string,
    _refreshToken: string,
    profile: any,
    done: VerifyCallback,
  ): Promise<GoogleUser> {
    try {
      console.log('[GoogleStrategy] Validate called');
      console.log('[GoogleStrategy] Profile:', JSON.stringify(profile));

      const { id, displayName, emails, photos } = profile;

      if (!emails || !emails[0]?.value) {
        console.error('[GoogleStrategy] No email found in profile');
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

      console.log('[GoogleStrategy] User validated:', user.email);
      done(null, user);
      return user;
    } catch (error) {
      console.error('[GoogleStrategy] Error in validate:', error);
      done(error as Error, undefined);
      return {} as GoogleUser;
    }
  }
}
