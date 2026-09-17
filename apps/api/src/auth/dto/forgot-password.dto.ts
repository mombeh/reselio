import { IsEmail, IsNotEmpty, Matches } from 'class-validator';

export class ForgotPasswordDto {
  @IsEmail()
  @Matches(
    /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,63})+$/,
    { message: 'Please provide a valid email address' },
  )
  @IsNotEmpty()
  email: string;
}
