import { IsEmail, IsNotEmpty, Matches } from 'class-validator';

export class ForgotPasswordDto {
  @IsEmail()
  @Matches(
    /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.com)+$/,
    { message: 'Please provide a valid email address with .com domain' },
  )
  @IsNotEmpty()
  email: string;
}
