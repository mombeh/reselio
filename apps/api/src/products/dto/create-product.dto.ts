import {
  IsString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  Min,
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
  price: number;

  @IsNumber()
  @Min(0, { message: 'Quantity must be greater than or equal to 0' })
  quantity: number;

  @IsString()
  @IsNotEmpty({ message: 'Category is required' })
  category: string;

  @IsString()
  @IsOptional()
  imageUrl?: string;
}
