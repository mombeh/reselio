import {
  IsString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  Min,
  Max,
  IsInt,
} from 'class-validator';

export class CreateProductDto {
  @IsString()
  @IsNotEmpty({ message: 'Product name is required' })
  name: string;

  @IsString()
  @IsNotEmpty({ message: 'Description is required' })
  description: string;

  @IsNumber()
  @Min(0, { message: 'Price must be greater than or equal to 0' })
  @Max(10000000, { message: 'Price must not exceed 10,000,000' })
  price: number;

  @IsNumber()
  @IsInt()
  @Min(0, { message: 'Quantity must be greater than or equal to 0' })
  @Max(1000000, { message: 'Quantity must not exceed 1,000,000' })
  quantity: number;

  @IsString()
  @IsNotEmpty({ message: 'Category is required' })
  category: string;

  @IsString()
  @IsOptional()
  imageUrl?: string;
}
