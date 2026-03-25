import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'resilioSecret',
    });
    console.log('JWT Strategy initialized with secret:', process.env.JWT_SECRET ? 'configured' : 'default');
  }

  async validate(payload: any) {
    console.log('JWT Strategy validate - payload:', payload);
    return { userId: payload.sub, email: payload.email };
  }
}