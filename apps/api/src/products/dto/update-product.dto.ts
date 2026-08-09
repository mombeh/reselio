import { IsString, IsNumber, IsOptional, Min, Max, IsInt } from 'class-validator';

export class UpdateProductDto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsNumber()
  @Min(0, { message: 'Price must be greater than or equal to 0' })
  @Max(10000000, { message: 'Price must not exceed 10,000,000' })
  @IsOptional()
  price?: number;

  @IsNumber()
  @IsInt()
  @Min(0, { message: 'Quantity must be greater than or equal to 0' })
  @Max(1000000, { message: 'Quantity must not exceed 1,000,000' })
  @IsOptional()
  quantity?: number;

  @IsString()
  @IsOptional()
  category?: string;

  @IsString()
  @IsOptional()
  imageUrl?: string;
}
