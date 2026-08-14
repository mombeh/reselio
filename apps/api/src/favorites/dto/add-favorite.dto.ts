import { IsString, IsNotEmpty } from 'class-validator';

export class AddFavoriteDto {
  @IsString()
  @IsNotEmpty({ message: 'Product ID is required' })
  productId: string;
}
