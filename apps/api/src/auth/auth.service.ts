import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
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
    };
  }

  async googleLogin(googleUser: any) {
    // Check if user already exists
    let user = await this.usersService.findByEmail(googleUser.email);
    
    if (!user) {
      // Create new user with Google profile
      const randomPassword = Math.random().toString(36).slice(-16);
      const hashedPassword = await bcrypt.hash(randomPassword, 10);
      
      user = await this.usersService.createWithGoogle(
        googleUser.email,
        googleUser.firstName + ' ' + googleUser.lastName,
        hashedPassword,
      );
    }
    
    // Generate JWT token
    const payload = { email: user.email, sub: user._id };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        email: user.email,
        name: user.name,
      },
    };
  }
}