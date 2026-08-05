import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateStoreDto {
  @IsString()
  @IsNotEmpty({ message: 'Store name is required' })
  name: string;

  @IsString()
  @IsNotEmpty({ message: 'Description is required' })
  description: string;

  @IsString()
  @IsNotEmpty({ message: 'Phone number is required' })
  phone: string;

  @IsString()
  @IsNotEmpty({ message: 'Address is required' })
  address: string;

  @IsString()
  @IsOptional()
  logo?: string;
}
