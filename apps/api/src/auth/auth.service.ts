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
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
      },
    };
  }

  async googleLogin(googleUser: any) {
    try {
      console.log('googleLogin - user:', googleUser);
      
      if (!googleUser || !googleUser.email) {
        console.error('googleLogin - no user or email');
        throw new Error('No user or email from Google');
      }

      // Check if user already exists
      let user = await this.usersService.findByEmail(googleUser.email);
      console.log('googleLogin - existing user:', !!user);
      
      if (!user) {
        // Create new user with Google profile
        console.log('googleLogin - creating new user');
        const randomPassword = Math.random().toString(36).slice(-16);
        const hashedPassword = await bcrypt.hash(randomPassword, 10);
        
        user = await this.usersService.createWithGoogle(
          googleUser.email,
          googleUser.name,
          hashedPassword,
        );
        console.log('googleLogin - new user created:', user._id);
      }
      
      // Generate JWT token
      const payload = { email: user.email, sub: user._id };
      console.log('googleLogin - generating token with payload:', payload);
      
      return {
        access_token: this.jwtService.sign(payload),
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
        },
      };
    } catch (error) {
      console.error('googleLogin error:', error);
      throw error;
    }
  }
}