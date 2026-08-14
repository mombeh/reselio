import {
  Controller,
  UseGuards,
  Post,
  Body,
  Req,
  Get,
  Param,
  Delete,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { FavoritesService } from './favorites.service';
import { AddFavoriteDto } from './dto/add-favorite.dto';

@Controller('favorites')
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @UseGuards(AuthGuard('jwt'))
  @Post()
  add(@Body() addFavoriteDto: AddFavoriteDto, @Req() req: any) {
    return this.favoritesService.add(req.user.userId, addFavoriteDto.productId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Delete(':productId')
  remove(@Param('productId') productId: string, @Req() req: any) {
    return this.favoritesService.remove(req.user.userId, productId);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get()
  findAll(@Req() req: any) {
    return this.favoritesService.findByUser(req.user.userId);
  }
}
