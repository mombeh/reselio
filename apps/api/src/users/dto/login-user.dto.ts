import { IsEmail, IsString, MinLength, Matches } from 'class-validator';

export class LoginUserDto {
  @IsEmail({}, { message: 'Please provide a valid email address' })
  @Matches(
    /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,63})+$/,
    { message: 'Please provide a valid email address' },
  )
  email: string;

  @IsString()
  @MinLength(1, { message: 'Password is required' })
  password: string;
}
