import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class GoogleAuthGuard extends AuthGuard('google') {
  getAuthenticateOptions() {
    return {
      scope: ['email', 'profile'],
      prompt: 'consent select_account',
    };
  }
}
